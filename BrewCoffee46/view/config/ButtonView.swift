import Foundation
import SwiftUI

/// # ButtonType
///
/// `minus` requires the minimum limit of the target and `plus` requires the maximum limit of that.
enum ButtonType {
    case minus(Double)
    case plus(Double)
}

extension ButtonType {
    internal func toSystemName() -> String {
        switch self {
        case .minus(_):
            return "minus.circle.fill"
        case .plus(_):
            return "plus.circle.fill"
        }
    }

    internal func toColor() -> (Color, Color) {
        switch self {
        case .minus(_):
            return (.white, .red)
        case .plus(_):
            return (.white, .accentColor)
        }
    }
}

struct ButtonView: View {
    private let buttonType: ButtonType
    private let isDisabled: Bool

    private let stepInteger: Double
    private let log10Step: Double

    @State private var targetInt: Double {
        didSet {
            target = targetInt / log10Step
        }
    }

    @Binding private var target: Double

    init(buttonType: ButtonType, step: Double, isDisabled: Bool, target: Binding<Double>) {
        self.buttonType = buttonType

        let log10Step =
            if floor(log10(step)) < 0.0 {
                pow(10.0, -floor(log10(step)))
            } else {
                1.0
            }
        self.log10Step = log10Step
        self.stepInteger = step * log10Step

        self.isDisabled = isDisabled
        self._target = target
        self.targetInt = target.wrappedValue * log10Step
    }

    var body: some View {
        Button(action: {
            switch buttonType {
            case .minus(let min):
                if target > min {
                    targetInt -= stepInteger
                }
            case .plus(let max):
                if target < max {
                    targetInt += stepInteger
                }
            }
        }) {
            HStack {
                Image(systemName: buttonType.toSystemName())
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .center)
                    .foregroundStyle(
                        isDisabled ? .primary.opacity(0.5) : buttonType.toColor().0,
                        isDisabled ? .primary.opacity(0.2) : buttonType.toColor().1
                    )
                    .onChange(of: target) { _, newValue in
                        targetInt = newValue * log10Step
                    }

            }
        }
        .buttonStyle(BorderlessButtonStyle())
        .disabled(isDisabled)
        .id(!isDisabled)
    }
}

#if DEBUG
    struct ButtonView_Previews: PreviewProvider {
        @State static var target: Double = 10.0

        static var previews: some View {
            HStack {
                ButtonView(
                    buttonType: .minus(1),
                    step: 0.1,
                    isDisabled: true,
                    target: $target
                )
                Divider()
                ButtonView(
                    buttonType: .plus(100),
                    step: 0.1,
                    isDisabled: true,
                    target: $target
                )
            }
            .previewDisplayName("disable = true")
            HStack {
                ButtonView(
                    buttonType: .minus(10),
                    step: 0.1,
                    isDisabled: false,
                    target: $target
                )
                Divider()
                ButtonView(
                    buttonType: .plus(100),
                    step: 0.1,
                    isDisabled: false,
                    target: $target
                )
            }
            .previewDisplayName("disable = false")
        }
    }
#endif
