import Foundation

enum RateLimiter {
    static func canConsume(key: String, maxPerDay: Int) -> Bool {
        remaining(key: key, maxPerDay: maxPerDay) > 0
    }

    @discardableResult
    static func consume(key: String, maxPerDay: Int) -> Bool {
        guard canConsume(key: key, maxPerDay: maxPerDay) else { return false }
        let storageKey = storageKey(key)
        let count = UserDefaults.standard.integer(forKey: storageKey)
        UserDefaults.standard.set(count + 1, forKey: storageKey)
        return true
    }

    static func remaining(key: String, maxPerDay: Int) -> Int {
        let count = UserDefaults.standard.integer(forKey: storageKey(key))
        return max(0, maxPerDay - count)
    }

    private static func storageKey(_ key: String) -> String {
        "\(key)_\(DateHelpers.todayKey())"
    }
}
