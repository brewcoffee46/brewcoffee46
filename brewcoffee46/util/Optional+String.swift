infix operator ??? : AssociativityLeft

func ??? (lhs: String?, rhs: String) -> String {
    if let value = lhs, !value.isEmpty {
        value
    } else {
        rhs
    }
}
