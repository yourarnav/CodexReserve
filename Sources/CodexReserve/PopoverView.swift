import AppKit
import SwiftUI

struct PopoverView: View {
    @ObservedObject var model: UsageModel

    var body: some View {
        let s = model.snapshot
        VStack(spacing: 14) {
            HStack {
                Text("Codex")
                    .font(.headline)
                Text(s.plan.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .glassCapsule()
                Spacer()
                Button {
                    model.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
                .disabled(model.isLoading)
                .help("Refresh now")
            }

            DoubleRingView(weekly: s.weeklyRemaining, fiveHour: s.fiveHourRemaining, size: 156)
                .padding(.top, 4)

            VStack(spacing: 8) {
                if s.fiveHourRemaining != nil || !s.isWeeklyOnly {
                    LimitRow(dot: .green,
                             title: "5-hour",
                             remaining: s.fiveHourRemaining,
                             reset: s.resetString(for: s.fiveHourResetAt))
                }
                if s.weeklyRemaining != nil || !s.isFiveHourOnly {
                    LimitRow(dot: .codexBlue,
                             title: "Weekly",
                             remaining: s.weeklyRemaining,
                             reset: s.resetString(for: s.weeklyResetAt))
                }
            }

            if let err = s.error {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text(updatedAgo(s.updatedAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button("Open Codex usage") {
                    if let url = URL(string: "https://chatgpt.com/codex/settings/usage") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.link)
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.link)
            }
            .font(.caption)
        }
        .padding(18)
        .frame(width: 264)
        // No card wrapper: the NSPopover itself is one continuous glass panel.
    }

    private func updatedAgo(_ date: Date) -> String {
        let secs = Int(Date().timeIntervalSince(date))
        if secs < 10 { return "Updated just now" }
        if secs < 60 { return "Updated \(secs)s ago" }
        return "Updated \(secs / 60)m ago · auto-refreshes"
    }
}

private struct LimitRow: View {
    var dot: Color
    var title: String
    var remaining: Double?
    var reset: String

    var body: some View {
        HStack {
            Circle().fill(dot).frame(width: 8, height: 8)
            Text(title)
                .font(.callout)
            Spacer()
            if let remaining {
                Text("\(Int(remaining.rounded()))% · \(reset)")
                    .font(.system(.callout, design: .monospaced).weight(.medium))
                    .foregroundStyle(.secondary)
            } else {
                Text("–")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Liquid Glass helpers (Tahoe) with graceful fallback

private struct GlassCapsuleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content.glassEffect(.regular, in: Capsule())
        } else {
            content
                .background(.ultraThinMaterial, in: Capsule())
        }
    }
}

extension View {
    func glassCapsule() -> some View { modifier(GlassCapsuleModifier()) }
}
