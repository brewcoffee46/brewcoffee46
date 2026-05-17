import SwiftUI

struct ArcView: View {
    @Binding var progressTime: Double
    @Binding var endDegrees: Double

    private let size: CGSize
    private let scale: Double

    private let center: CGPoint
    private let radius: CGFloat

    init(progressTime: Binding<Double>, endDegrees: Binding<Double>, size: CGSize, scale: Double = 0.8) {
        self._progressTime = progressTime
        self._endDegrees = endDegrees
        self.size = size
        self.scale = scale

        self.center = CGPoint(x: size.width / 2, y: size.height / 2)
        self.radius = (size.width < size.height ? size.width : size.height) / 2 * CGFloat(self.scale)
    }

    private func stopwatchGradient() -> LinearGradient {
        if progressTime < 0 {
            return LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .green.opacity(0.5), location: 0.0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .blue.opacity(0.1), location: 0.0),
                    .init(color: .blue.opacity(0.5), location: fillColorLocation()),
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    var body: some View {
        Arc(
            startDegrees: 0.0,
            endDegrees: endDegrees,
            center: center,
            radius: radius
        )
        .fill(stopwatchGradient())
        .rotationEffect(Angle.degrees(-90.0), anchor: .center)
    }

    private func fillColorLocation() -> Double {
        let value = Double(Int(progressTime) % 10) * 0.1 + ((progressTime - floor(progressTime)) * 0.1)
        if (Int(progressTime) / 10) % 2 != 0 {
            return value
        } else {
            return 1.0 - value
        }
    }
}

struct Arc: Shape {
    let startDegrees: Double
    let endDegrees: Double
    let center: CGPoint
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        return Path { p in
            p.move(to: center)
            p.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(self.startDegrees),
                endAngle: .degrees(self.endDegrees),
                clockwise: false
            )
            p.addArc(
                center: center,
                radius: radius / 1.3,
                startAngle: .degrees(self.endDegrees),
                endAngle: .degrees(self.startDegrees),
                clockwise: true
            )
        }
    }
}

#if DEBUG
    struct ArcView_Previews: PreviewProvider {
        @State static var progressTime1: Double = 55
        @State static var progressTime2: Double = -2
        @State static var endDegree: Double = 270.0

        static var previews: some View {
            VStack {
                GeometryReader { geometry in
                    ArcView(
                        progressTime: $progressTime1,
                        endDegrees: $endDegree,
                        size: geometry.size,
                        scale: 0.7
                    )
                }
                GeometryReader { geometry in
                    ArcView(
                        progressTime: $progressTime2,
                        endDegrees: $endDegree,
                        size: geometry.size,
                        scale: 0.7
                    )
                }
            }
        }
    }
#endif
