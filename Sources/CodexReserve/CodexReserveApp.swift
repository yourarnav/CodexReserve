import AppKit
import Combine
import SwiftUI
import os

private let hoverLog = Logger(subsystem: "com.codexreserve.app", category: "hover")

/// Classic AppKit status-item hosting. We deliberately do NOT use SwiftUI's
/// MenuBarExtra here: the process ran fine but the extra never appeared in
/// the menu bar, so we drive NSStatusBar directly — the path that always shows.
@main
struct CodexReserveMain {
    @MainActor
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory) // menu bar only, no Dock icon
        let delegate = AppDelegate()
        AppDelegate.holder = delegate // NSApplication.delegate is weak
        app.delegate = delegate
        app.run()
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    static var holder: AppDelegate?

    private var statusItem: NSStatusItem?
    private let popover = NSPopover()
    private var popoverHost: NSHostingController<PopoverView>?
    private let model = UsageModel()
    private var cancellable: AnyCancellable?
    private var closeTimer: Timer?
    private var mouseMonitor: Any?
    private var keyMonitor: Any?
    /// Guards the startup fetch: workspace notifications fire for every app
    /// launch/quit system-wide, so without this two fetches could run
    /// concurrently and double-fire sounds.
    private var isStartingFetch = false
    /// Standby while Codex isn't running: stop background work and hide the
    /// icon, but stay alive so we reappear when Codex launches.
    /// Read synchronously from the hot mouse-move path (stale reads harmless).
    nonisolated(unsafe) private var tearingDown = false
    private var cachedIconRect = NSRect.zero
    private var cachedIconRectAt = Date.distantPast

    func applicationDidFinishLaunching(_ notification: Notification) {
        // model.start() happens via updateVisibility() below (only if Codex runs).

        ensureStatusItem()
        // Follow Codex: we only show while Codex runs — if it isn't running
        // (launch or quit), stand by with no icon/timers until it returns.
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(appPresenceChanged(_:)),
            name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(appPresenceChanged(_:)),
            name: NSWorkspace.didTerminateApplicationNotification, object: nil)
        updateVisibility()

        let host = NSHostingController(rootView: PopoverView(model: model))
        popoverHost = host
        popover.contentViewController = host
        popover.behavior = .transient
        updatePopoverSize()

        // Hover to open (no click needed). NOTE: local NSTrackingAreas do NOT
        // fire on status-item buttons — the menu bar is owned by Control
        // Center, so the button is effectively remote. Instead we watch the
        // mouse globally (movement needs no permission) and hit-test against
        // the icon's real screen rect ourselves.
        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] _ in
            guard let self, !self.tearingDown else { return }
            Task { @MainActor in self.handleGlobalMouseMove() }
        }
        // Cmd+Q to quit: a real Quit menu item (works when we're active) plus
        // a local key monitor so Cmd+Q also quits while our key popover is open.
        // (When another app is frontmost, Cmd+Q correctly goes to that app.)
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(NSMenuItem(title: "Quit CodexReserve",
                                   action: #selector(NSApplication.terminate(_:)),
                                   keyEquivalent: "q"))
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)
        NSApplication.shared.mainMenu = mainMenu
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            var result: NSEvent? = event
            MainActor.assumeIsolated {
                if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command,
                   event.charactersIgnoringModifiers?.lowercased() == "q",
                   self.popover.isShown {
                    NSApplication.shared.terminate(nil)
                    result = nil
                }
            }
            return result
        }
        // One-shot: confirm the icon has a real screen rect for hit-testing.
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            Task { @MainActor in
                let r = self?.iconScreenRect() ?? .zero
                hoverLog.info("icon rect x=\(r.origin.x, privacy: .public) y=\(r.origin.y, privacy: .public) w=\(r.width, privacy: .public) h=\(r.height, privacy: .public)")
            }
        }

        // Redraw the rings + tooltip on every refresh.
        cancellable = model.$snapshot
            .receive(on: RunLoop.main)
            .sink { [weak self] snap in
                guard let self, let button = self.statusItem?.button else { return }
                button.image = RingIcon.make(snapshot: snap)
                button.title = ""
                button.toolTip = self.tooltip(for: snap)
                self.updatePopoverSize()
            }
    }

    private func ensureStatusItem() {
        if statusItem != nil { return }
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = item
        item.button?.image = RingIcon.make(snapshot: model.snapshot)
        item.button?.imagePosition = .imageOnly // the image already contains both numbers
        item.button?.title = ""
        item.button?.appearsDisabled = false // never render faded
        item.button?.target = self
        item.button?.action = #selector(togglePopover(_:))
        item.button?.toolTip = tooltip(for: model.snapshot)
    }

    private func updatePopoverSize() {
        guard let hostView = popoverHost?.view else { return }
        hostView.layoutSubtreeIfNeeded()
        let fit = hostView.fittingSize
        if fit.width > 10 && fit.height > 10 {
            popover.contentSize = NSSize(width: min(340, max(300, fit.width)),
                                        height: min(520, max(220, fit.height)))
        } else {
            popover.contentSize = NSSize(width: 300, height: 380)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let mouseMonitor { NSEvent.removeMonitor(mouseMonitor) }
        if let keyMonitor { NSEvent.removeMonitor(keyMonitor) }
        mouseMonitor = nil
        keyMonitor = nil
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        cancellable?.cancel()
        cancellable = nil
        closeTimer?.invalidate()
        closeTimer = nil
        model.stop()
    }

    @objc private func togglePopover(_ sender: Any?) {
        cancelClose()
        guard statusItem?.button != nil else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            showPopover(key: true)
        }
    }

    private func showPopover(key: Bool) {
        guard let button = statusItem?.button, !popover.isShown else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        // Hover opens passively WITHOUT stealing keyboard focus from the
        // front app; only an explicit click takes key.
        if key { popover.contentViewController?.view.window?.makeKey() }
    }

    private func scheduleClose(after delay: Double) {
        guard closeTimer == nil else { return } // one pending close at a time
        closeTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.closeTimer = nil
                if self.popover.isShown {
                    self.popover.performClose(nil)
                }
            }
        }
    }

    private func cancelClose() {
        closeTimer?.invalidate()
        closeTimer = nil
    }

    /// Screen rect of our menu bar icon (for hover hit-testing).
    /// Cached 0.5s: the window lookup is IPC to Control Center, too
    /// expensive to run on every mouse-move event uncached.
    private func iconScreenRect() -> NSRect {
        if Date().timeIntervalSince(cachedIconRectAt) < 0.5 { return cachedIconRect }
        guard let button = statusItem?.button, let win = button.window else {
            cachedIconRect = .zero
            cachedIconRectAt = Date()
            return .zero
        }
        let rect = win.convertToScreen(button.convert(button.bounds, to: nil))
        cachedIconRect = rect
        cachedIconRectAt = Date()
        return rect
    }

    private func handleGlobalMouseMove() {
        let mouse = NSEvent.mouseLocation // screen coords, origin bottom-left
        let iconRect = iconScreenRect() // single computation (window IPC on hot path)
        if !iconRect.isEmpty, iconRect.contains(mouse) {
            cancelClose()
            showPopover(key: false)
            return
        }
        guard popover.isShown,
              let win = popover.contentViewController?.view.window else { return }
        if win.frame.insetBy(dx: -10, dy: -10).contains(mouse) {
            cancelClose() // travelling between icon and popover
        } else {
            scheduleClose(after: 0.25)
        }
    }

    private func tooltip(for snap: UsageSnapshot) -> String {
        guard snap.effectiveRemaining != nil else { return "Codex limits" }
        if snap.isWeeklyOnly, let week = snap.weeklyRemaining {
            return "Codex · \(Int(week.rounded()))% weekly"
        }
        if snap.isFiveHourOnly, let five = snap.fiveHourRemaining {
            return "Codex · \(Int(five.rounded()))% 5-hour"
        }
        let five = snap.fiveHourRemaining.map { "\(Int($0.rounded()))% 5-hour" } ?? "5-hour –"
        let week = snap.weeklyRemaining.map { "\(Int($0.rounded()))% weekly" } ?? "weekly –"
        return "Codex · \(five) · \(week)"
    }

    // MARK: - Follow Codex (show while it runs, stand by when it quits)
    // Matching rules live in TargetMatch.swift (unit-tested).

    private func targetRunning() -> Bool {
        NSWorkspace.shared.runningApplications.contains {
            TargetMatch.isTarget(bundleID: $0.bundleIdentifier,
                                 executableName: $0.executableURL?.lastPathComponent)
        }
    }

    /// Set once Codex has been seen in this run. Distinguishes "launched
    /// with no Codex" (explain, then stand by) from "Codex quit on us" (go quietly).
    private var didRunWithCodex = false

    private func updateVisibility() {
        let running = targetRunning()
        if !running {
            // Stand by (don't terminate): hide the icon, stop polling, stay
            // alive so we reappear automatically when Codex launches.
            tearingDown = true
            cachedIconRect = .zero
            model.stop()
            if popover.isShown { popover.performClose(nil) }
            if let item = statusItem {
                NSStatusBar.system.removeStatusItem(item)
                statusItem = nil
            }
            if didRunWithCodex {
                hoverLog.info("codex quit — standing by")
            } else {
                // Launched with no Codex around: say so instead of
                // vanishing silently (which looks broken on a stranger's Mac).
                let alert = NSAlert()
                alert.messageText = "Codex isn't running"
                alert.informativeText = "Open Codex first — CodexReserve will appear in the menu bar."
                alert.alertStyle = .informational
                alert.addButton(withTitle: "OK")
                NSApplication.shared.activate()
                alert.runModal()
                hoverLog.info("launched without Codex — explained and standing by")
            }
            return
        }
        tearingDown = false
        ensureStatusItem()
        didRunWithCodex = true
        // First sighting of Codex in this run: kick off polling if needed.
        // Codex windows move slowly; 60s keeps the ring "continuously" fresh
        // without hammering the backend.
        if !model.polling && !isStartingFetch {
            isStartingFetch = true
            Task { @MainActor in
                defer { self.isStartingFetch = false }
                do {
                    let snap = try await UsageService.fetchSnapshot()
                    self.model.start(seeded: snap)
                } catch {
                    let msg = (error as NSError).localizedDescription
                    self.model.start(seeded: nil, error: msg)
                }
            }
        }
    }

    @objc private func appPresenceChanged(_ note: Notification) {
        updateVisibility()
    }

    // MARK: - Menu bar icon lives in RingIcon.swift (pure AppKit, always renders)
}
