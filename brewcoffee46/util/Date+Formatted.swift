import Foundation

extension Date {
    func formattedWithSec() -> String {
        let f = DateFormatter()
        f.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMdkHms", options: 0, locale: .current)

        return f.string(from: self)
    }
}
