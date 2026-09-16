import Foundation

/// Which running app counts as "Codex is open".
/// Codex lives inside ChatGPT.app (bundle ID com.openai.codex).
enum TargetMatch {
    static let bundleIDs: Set<String> = ["com.openai.codex"]
    /// Main executable name. Helpers/renderers may share the bundle ID and
    /// outlive the main app, so the ID alone is not enough.
    static let executable = "ChatGPT"

    /// Pure matching logic: main app only, never helpers.
    static func isTarget(bundleID: String?, executableName: String?) -> Bool {
        guard let bundleID, bundleIDs.contains(bundleID) else { return false }
        guard let executableName else { return true } // fail open (old behavior)
        return executableName == executable
    }
}
