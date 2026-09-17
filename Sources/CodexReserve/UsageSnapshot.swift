import Foundation

struct UsageSnapshot: Equatable {
    var plan: String = "plus"
    /// % remaining (0...100). Converted from API `used_percent`.
    var fiveHourRemaining: Double?
    var weeklyRemaining: Double?
    var fiveHourResetAt: Date?
    var weeklyResetAt: Date?
    var updatedAt: Date = Date()
    var error: String?

    /// Binding limit — Codex blocks when EITHER window is exhausted.
    var effectiveRemaining: Double? {
        switch (fiveHourRemaining, weeklyRemaining) {
        case let (a?, b?): return min(a, b)
        case let (a?, nil): return a
        case let (nil, b?): return b
        case (nil, nil): return nil
        }
    }

    /// Plan shapes differ (e.g. Pro has no 5-hour window). UI shows a solo
    /// ring for whichever window actually exists, instead of hardcoding plans.
    var isWeeklyOnly: Bool { fiveHourRemaining == nil && weeklyRemaining != nil }
    var isFiveHourOnly: Bool { weeklyRemaining == nil && fiveHourRemaining != nil }

    static func fromAPI(_ data: Data) throws -> UsageSnapshot {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        var snap = UsageSnapshot()
        if let plan = json["plan_type"] as? String { snap.plan = plan }
        if let rl = json["rate_limit"] as? [String: Any] {
            // Classify each window by its duration, not its role: the backend
            // has swapped primary/secondary roles before. Role is the fallback.
            let primary = rl["primary_window"] as? [String: Any]
            let secondary = rl["secondary_window"] as? [String: Any]
            let fiveCandidates = [primary, secondary].compactMap { $0 }
            let weeklyCandidates = [secondary, primary].compactMap { $0 }
            if let w = fiveCandidates.first(where: { isHours($0, hours: 5) }) ?? primary {
                snap.fiveHourRemaining = remaining(from: w)
                snap.fiveHourResetAt = resetDate(from: w)
            }
            if let w = weeklyCandidates.first(where: { isHours($0, hours: 24 * 7) }) ?? secondary {
                snap.weeklyRemaining = remaining(from: w)
                snap.weeklyResetAt = resetDate(from: w)
            }
        }
        snap.updatedAt = Date()
        return snap
    }

    private static func remaining(from window: [String: Any]) -> Double? {
        guard let used = window["used_percent"] as? Double else { return nil }
        return max(0, min(100, 100 - used))
    }

    /// True when the window's duration matches `hours` (±25%).
    private static func isHours(_ window: [String: Any], hours: Double) -> Bool {
        guard let secs = window["limit_window_seconds"] as? Double else { return false }
        return abs(secs - hours * 3600) / (hours * 3600) <= 0.25
    }

    private static func resetDate(from window: [String: Any]) -> Date? {
        if let ts = window["reset_at"] as? Double {
            return Date(timeIntervalSince1970: ts)
        }
        if let ts = window["reset_at"] as? Int {
            return Date(timeIntervalSince1970: Double(ts))
        }
        return nil
    }

    /// "4h52m", "12m", "3d4h", "—" when unknown/expired.
    func resetString(for date: Date?, now: Date = Date()) -> String {
        guard let date else { return "—" }
        let secs = Int(date.timeIntervalSince(now))
        if secs <= 0 { return "soon" }
        let m = secs / 60
        if m < 60 { return "\(m)m" }
        let h = m / 60
        if h < 48 { return "\(h)h\(m % 60)m" }
        return "\(h / 24)d\(h % 24)h"
    }
}
