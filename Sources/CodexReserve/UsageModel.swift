import SwiftUI
import os

private let log = Logger(subsystem: "com.codexreserve.app", category: "usage")

@MainActor
final class UsageModel: ObservableObject {
    @Published var snapshot = UsageSnapshot()
    @Published var isLoading = false

    private var timer: Timer?

    /// Whether the 60s poll loop is active.
    var polling: Bool { timer != nil }

    private var sounds = SoundNotifier()

    /// Fetch once and hand the snapshot to the caller.
    /// Used by the launcher so the icon paints with real numbers immediately.
    func fetchOnce() async -> UsageSnapshot? {
        do {
            return try await UsageService.fetchSnapshot()
        } catch {
            log.error("Usage refresh failed: \((error as NSError).localizedDescription, privacy: .public)")
            return nil
        }
    }

    /// Start the loop, seeding from an already-fetched snapshot (no double fetch).
    func start(seeded snap: UsageSnapshot?) {
        if let snap {
            snapshot = snap
            let five = snap.fiveHourRemaining.map { "\(Int($0.rounded()))%" } ?? "?"
            let week = snap.weeklyRemaining.map { "\(Int($0.rounded()))%" } ?? "?"
            log.info("Usage updated: 5h \(five, privacy: .public) weekly \(week, privacy: .public) plan \(snap.plan, privacy: .public)")
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func start() {
        start(seeded: nil)
        refresh()
    }

    /// Pause background work (used while the icon is hidden).
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            do {
                let snap = try await UsageService.fetchSnapshot()
                let played = self.sounds.check(old: self.snapshot, new: snap)
                if !played.isEmpty {
                    log.info("Limit chime: \(played.joined(separator: ","), privacy: .public)")
                }
                self.snapshot = snap
                let five = snap.fiveHourRemaining.map { "\(Int($0.rounded()))%" } ?? "?"
                let week = snap.weeklyRemaining.map { "\(Int($0.rounded()))%" } ?? "?"
                log.info("Usage updated: 5h \(five, privacy: .public) weekly \(week, privacy: .public) plan \(snap.plan, privacy: .public)")
            } catch {
                let msg = (error as NSError).localizedDescription
                var s = self.snapshot
                s.error = msg
                self.snapshot = s
                log.error("Usage refresh failed: \(msg, privacy: .public)")
            }
            self.isLoading = false
        }
    }
}
