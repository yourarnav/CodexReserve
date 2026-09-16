# CodexBar — liquid menu bar rings for Codex Plus limits

Tiny macOS menu bar utility. One circle, two rings:

> **Unofficial community project**, not affiliated with OpenAI. It reads your
> local `~/.codex/auth.json` and uses the same private usage endpoint as the
> Codex CLI — if OpenAI changes that endpoint, this breaks until updated.

- **Outer ring = weekly limit** (royal blue, easy on eyes), **inner ring = 5-hour** (Watch green). Fixed hues like the Watch — arc length + % + chimes tell the story.
- **Menu bar:** `weekly%W ⭕ 5h%` — both numbers stay; between them a single green 5-hour ring. Hover/click for the popover with double rings, resets.
- **Follows Codex:** open this app while Codex runs and the icon appears; quit Codex and it quits itself entirely. Nothing starts at login — when it's off, it's fully off (0 MB, 0 CPU).
- Hover the icon to pop open (no click needed); it closes when the mouse leaves. Click still toggles.
- **Colors:** fixed Watch hues — royal blue weekly, green 5-hour. Arc length + % + chimes carry the state (no hue shifting).
- **Sounds:** gentle `Glass` chime when either limit drains through 50%, `Ping` at 20%. Once per crossing (re-arms after the window resets).
- **Fonts:** system in the menu bar (blends in); New York serif hero % + SF Mono rows in the popover.
- **Quit:** `Cmd+Q` while the popover is open, or the Quit link inside it.
- **Footprint (measured):** ~17 MB RAM flat, ~0.1% CPU steady-state including the 60s refreshes (0.15 CPU-sec per 120s wall), 8s sample 99.9% idle, `leaks` shows zero nodes from app code. Hidden state costs strictly less (polling paused).
- **Icon:** Apple-esque dark squircle + blue/green double ring (`icon/make-icon.swift` → `Resources/AppIcon.icns`).
- **Liquid design:** Tahoe `.glassEffect()` with ultra-thin-material fallback on older macOS.
- **Live:** auto-refreshes every 60s from the official ChatGPT usage endpoint using your existing `~/.codex/auth.json` (same source the Codex CLI uses). Nothing else leaves your Mac.

## Run

Requirements: macOS 14+, Xcode 26+ (Swift 6), Codex signed in once.

```bash
cd Codex-Muse
./install.sh   # build + install to /Applications + start at every login
```

(Or `./build-app.sh` + `open CodexBar.app` for a one-off run without installing.)

No `codex` binary needed. Just sign in to Codex once (CLI, IDE extension, or app) so `~/.codex/auth.json` exists — CodexBar re-reads it on every refresh, so token rotations are picked up automatically.

If the session expires (401), the popover tells you to open Codex and sign in again.

## Files

- `Package.swift` — SwiftPM, macOS 14+, no dependencies
- `Sources/CodexBar/CodexBarApp.swift` — AppKit status-item hosting, hover-to-open, Cmd+Q, follow-Codex lifecycle
- `Sources/CodexBar/RingIcon.swift` — hand-drawn menu bar strip (`weekly%W ⭕ 5h%`)
- `Sources/CodexBar/UsageService.swift` — auth + `GET chatgpt.com/backend-api/codex/usage` with 403 retry
- `Sources/CodexBar/UsageSnapshot.swift` — `used_percent → remaining` parsing (duration-classified), reset strings
- `Sources/CodexBar/RingViews.swift` — Canvas double ring (Watch blue/green)
- `Sources/CodexBar/SoundNotifier.swift` — edge-triggered 50%/20% chimes
- `Sources/CodexBar/PopoverView.swift` — glass popover card
- `Sources/CodexBar/UsageModel.swift` — 60s refresh loop (pausable)
- `icon/make-icon.swift` + `icon/make-icon.sh` — white squircle app icon → `Resources/AppIcon.icns`
- `install.sh` — copy to /Applications (no autostart, by design)
