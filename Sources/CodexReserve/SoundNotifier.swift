import AppKit

/// Gentle chimes when a limit drains through 50% and 20% remaining.
///
/// Edge-triggered with hysteresis: each level fires once on a downward
/// crossing and re-arms only after climbing 3+ points back above the level,
/// so hovering near a threshold never spams. The very first sighting arms
/// silently — no chime on launch when already below a level.
/// `check` plays the sound and also returns the names played (test hook).
struct SoundNotifier {
    private var armed50Five = true
    private var armed20Five = true
    private var armed50Weekly = true
    private var armed20Weekly = true

    mutating func check(old: UsageSnapshot, new: UsageSnapshot) -> [String] {
        var a50f = armed50Five, a20f = armed20Five
        var a50w = armed50Weekly, a20w = armed20Weekly
        defer {
            armed50Five = a50f; armed20Five = a20f
            armed50Weekly = a50w; armed20Weekly = a20w
        }
        return Self.checkWindow(old: old.fiveHourRemaining, new: new.fiveHourRemaining,
                                armed50: &a50f, armed20: &a20f)
            + Self.checkWindow(old: old.weeklyRemaining, new: new.weeklyRemaining,
                               armed50: &a50w, armed20: &a20w)
    }

    private static func checkWindow(old: Double?, new: Double?,
                                    armed50: inout Bool, armed20: inout Bool) -> [String] {
        guard let new else { return [] }
        guard let old else {
            armed50 = new > 50
            armed20 = new > 20
            return []
        }
        var played: [String] = []
        if old > 50 && new <= 50 && armed50 {
            armed50 = false
            played.append(chime(named: "Glass"))
        }
        if old > 20 && new <= 20 && armed20 {
            armed20 = false
            played.append(chime(named: "Ping"))
        }
        if new > 53 { armed50 = true }
        if new > 23 { armed20 = true }
        return played
    }

    @discardableResult
    private static func chime(named name: String) -> String {
        NSSound(named: name)?.play()
        return name
    }
}
