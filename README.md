# CodexBar

Two rings. Your menu bar. Done.

<p align="center">
  <img src="screenshot-popover-v2.png" alt="Popover: double rings, limits, resets" width="300" />
</p>

Everyone else is building the Bloomberg Terminal for AI tokens. One app tracking Anthropic and OpenAI and local llamas and OpenRouter and your token history and your token future and probably your token horoscope. Settings pages with forty toggles. A second app living inside the first app.

CodexBar answers exactly one question: can I keep coding right now?

Blue ring: your week. Green ring: your next five hours. A chime when either gets thin. Then it quits with Codex and vanishes, because software should know when to leave the room.

## No, it does not do that other thing

No multi provider dashboard. No token historian. No spend charts. No burn down prophecy. No widgets, no CLI, no Raycast extension, no iCloud sync, no confetti. If you need confetti when your quota resets, this is not your app, and honestly, examine your life.

## Yes, it is native

Pure Swift. SwiftUI and AppKit, zero dependencies, 17 MB of RAM, roughly zero CPU. No Electron. No web view in a trench coat. It reads the auth Codex already put on your Mac, asks OpenAI how much you have left once a minute, and minds its own business otherwise.

## Run it

macOS 14 or later, Xcode 26 or later, Codex signed in once.

```bash
git clone https://github.com/yourarnav/CodexBar.git
cd CodexBar
./install.sh
```

Open Codex, open CodexBar from Launchpad. Quit Codex and it quits with it. Nothing starts at login. It will never ask for your attention except the two times per cycle you actually want it to.

Unofficial, not affiliated with OpenAI. If they move the endpoint, it breaks until someone moves it back. MIT licensed, do whatever you want with it.
