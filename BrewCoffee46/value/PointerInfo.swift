import BrewCoffee46Core
import SwiftUI

struct PointerInfo {
    // Degree of the pointers.
    public let pointerDegrees: [Double]

    init(_ pointerDegrees: [Double]) {
        self.pointerDegrees = pointerDegrees
    }

    init(_ dripInfo: DripInfo) {
        let totalWaterAmount = dripInfo.waterAmount.totalAmount()
        var thisDegree = 0.0
        var degrees: [Double] = []
        for e in dripInfo.waterAmount.toArray() {
            degrees.append(thisDegree)
            thisDegree = (e / totalWaterAmount) * 360 + thisDegree
        }
        self.pointerDegrees = degrees
    }
}

extension PointerInfo {
    static public func defaultValue() -> PointerInfo {
        PointerInfo.init(DripInfo.defaultValue())
    }
}
