public typealias MilliSecond = UInt64

extension MilliSecond {
    public static func fromSecond(_ sec: Double) -> Self {
        Self(roundCentesimal(sec * 1000.0))
    }

    public var second: Double {
        Double(self) / 1000.0
    }
}
