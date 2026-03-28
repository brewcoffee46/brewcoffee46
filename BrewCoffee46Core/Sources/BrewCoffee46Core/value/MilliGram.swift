public typealias MilliGram = UInt64

extension MilliGram {
    public static func fromGram(_ gram: Double) -> Self {
        Self(roundCentesimal(gram * 1000.0))
    }

    public var gram: Double {
        Double(self) / 1000.0
    }
}
