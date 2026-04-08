import BrewCoffee46Core
import Factory
import SwiftUI

struct NumberPickerView: View {
    private let digit: Int
    private let max: Double
    private let min: Double

    @State private var numbers: TupleFloat

    @Binding private var target: Double
    @Binding private var isDisable: Bool

    static func getNumbers(_ digit: Int, _ target: Double) -> TupleFloat {
        switch TupleFloat.fromDouble(digit, target) {
        case .success(let value):
            return value
        case .failure(_):
            return TupleFloat.unsafeFromDouble(1, target)
        }
    }

    init(digit: Int, max: Double, min: Double, target: Binding<Double>, isDisable: Binding<Bool>) {
        self.digit = digit
        self.max = max
        self.min = min
        self._target = target
        self._isDisable = isDisable

        self.numbers = NumberPickerView.getNumbers(digit, target.wrappedValue)
    }

    private func checkMinMax(integer: Int, decimal: Int) -> Bool {
        let value = TupleFloat(integer: integer, decimal: decimal, digit: digit).toDouble()
        return value >= min && value < max
    }

    var body: some View {
        HStack {
            Spacer()
            Group {
                Picker("NumberPicker integer", selection: $numbers.integer) {
                    ForEach(0..<Int(floor(max)), id: \.self) { i in
                        Text("\(i)")
                            .tag(i)
                            .foregroundStyle(isDisable ? Color.primary.opacity(0.5) : Color.primary)
                    }
                }
                .onChange(of: numbers.integer) { (oldValue, newValue) in
                    if checkMinMax(integer: newValue, decimal: numbers.decimal) {
                        target = numbers.toDouble()
                    } else {
                        numbers.integer = oldValue
                    }
                }
                Text(".").foregroundStyle(isDisable ? Color.primary.opacity(0.5) : Color.primary)
                Picker("NumberPicker decimal", selection: $numbers.decimal) {
                    ForEach(0..<Int(pow(10.0, Double(digit))), id: \.self) { i in
                        Text("\(i)")
                            .tag(i)
                            .foregroundStyle(isDisable ? Color.primary.opacity(0.5) : Color.primary)
                    }
                }
                .frame(width: 100)
                .onChange(of: numbers.decimal) { (oldValue, newValue) in
                    if checkMinMax(integer: numbers.integer, decimal: newValue) {
                        target = numbers.toDouble()
                    } else {
                        numbers.decimal = oldValue
                    }
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 100)
            .clipped()
            .disabled(isDisable)
            .onChange(of: target) { _, newValue in
                self.numbers = NumberPickerView.getNumbers(digit, newValue)
            }

            Text("\(weightUnit)").fixedSize()
            Spacer()
        }
    }
}

#if DEBUG
    struct NumberPickerView_Previews: PreviewProvider {
        @State static var showTips = true
        @State static var target: Double = 98.7
        @State static var target2: Double = 5.6
        @State static var isDisable: Bool = false

        static var previews: some View {
            VStack {
                Text("\(target)")
                NumberPickerView(
                    digit: 1,
                    max: 100.0,
                    min: 0.0,
                    target: $target,
                    isDisable: $isDisable
                )
                Divider()
                Text("\(target2) (min: 0.1)")
                NumberPickerView(
                    digit: 1,
                    max: 100.0,
                    min: 0.1,
                    target: $target2,
                    isDisable: $isDisable
                )
            }
        }
    }
#endif
