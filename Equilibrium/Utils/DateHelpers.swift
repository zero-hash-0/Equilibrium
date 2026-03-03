import Foundation

enum DateHelpers {
    private static let dayKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func todayKey() -> String {
        dayKeyFormatter.string(from: Date())
    }

    static func dayKey(for date: Date) -> String {
        dayKeyFormatter.string(from: date)
    }

    static func startOfDay(_ date: Date = Date()) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    static func startOfDay(daysAgo: Int) -> Date {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        return startOfDay(date)
    }
}
