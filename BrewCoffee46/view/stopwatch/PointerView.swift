import BrewCoffee46Core
import SwiftUI

/// # A pointer of the scale.
///
/// These implementation refer from: https://talk.objc.io/episodes/S01E192-analog-clock
struct PointerView: View {
    let waterAmount: Double
    let degree: Double
    let isOnGoing: Bool

    private let offset: Double = 10

    var body: some View {
        ZStack {
            VStack {
                Text(String(format: "%.1f", waterAmount) + weightUnit)
                    .font(Font(UIFont.monospacedSystemFont(ofSize: 17, weight: .regular)))
                    .foregroundColor(
                        isOnGoing ? .accentColor : .primary
                    )
                    .fixedSize()
                    .frame(width: 30)
                    .rotationEffect(
                        Angle.degrees(-degree)
                    )
                    .offset(y: -offset)
                Spacer()
                Pointer(offset: offset, lineLength: isOnGoing ? 90 : 115)
                    .stroke(lineWidth: isOnGoing ? 1.5 : 1)
                    .opacity(0.5)
                    .foregroundColor(
                        isOnGoing ? .accentColor : .primary
                    )
            }
            .rotationEffect(
                Angle.degrees(degree)
            )
        }
    }
}

struct Pointer: Shape {
    var circleRadius: CGFloat = 5
    var offset: Double
    var lineLength: CGFloat

    func path(in rect: CGRect) -> Path {
        return Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY - (offset * 1.5)))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.midY - circleRadius - lineLength))
        }
    }
}

#if DEBUG
    struct PointerView_Previews: PreviewProvider {
        @State static var progressTime: Double = 12.34
        static var waterAmount = 20.0
        static var degree = 120.0

        static var previews: some View {
            ZStack {
                PointerView(
                    waterAmount: 20,
                    degree: 30,
                    isOnGoing: false
                )
                PointerView(
                    waterAmount: 50,
                    degree: 80,
                    isOnGoing: false
                )
                PointerView(
                    waterAmount: 90,
                    degree: 120,
                    isOnGoing: true
                )
                PointerView(
                    waterAmount: 150,
                    degree: 170,
                    isOnGoing: false
                )
            }
            .frame(width: 300, height: 350)
        }
    }
#endif
