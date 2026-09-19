# CodexReserve

[![Downloads](https://img.shields.io/github/downloads/yourarnav/CodexReserve/CodexReserve.dmg?label=Downloads&logo=github)](https://github.com/yourarnav/CodexReserve/releases)
<p align="center">
  <img src="docs/screenshot-popover-v2.png" alt="CodexReserve showing Codex usage limits" width="300" />
</p>

<p align="center">
  <a href="https://codex-reserve.vercel.app/">Live preview</a>
</p>

Look up. Know if you can keep coding. Continue with your life.

## Get it

One command, no building:

```bash
brew install --cask yourarnav/tap/codexreserve
```

Prefer the manual way? Grab `CodexReserve.dmg` from
[Releases](https://github.com/yourarnav/CodexReserve/releases),
open it, drag CodexReserve into Applications. The code is all on this page,
go read it first if you like.

First launch: your Mac will call it damaged because this is free and
self signed, not notarized. Clear the flag once, then open it normally:

```bash
xattr -dr com.apple.quarantine /Applications/CodexReserve.app
```

That warning is the price of free.

## It does one job

The **<span style="color:#1e9e4a">green ring</span>** is your 5-hour Codex limit.

The **<span style="color:#4169e1">blue ring</span>** is your weekly limit.

Pro accounts with no 5-hour window show the weekly ring solo. The app
shows whatever windows your account actually has.

Hover for the numbers and reset times.

CodexReserve refreshes quietly in the background and gives you a chime as your limits run down.

No dashboard to maintain.
No account to create.
No provider to configure.

## Built like a Mac app

CodexReserve is native Swift.

**SwiftUI + AppKit. Zero dependencies.**

No Electron.
No web view wearing a `.app` costume.
No local server.
No background process reconsidering its purpose six hours after you stopped coding.

## Deliberately not everything

CodexReserve does not track Claude, Gemini, OpenRouter, your local llama farm, API spend, historical token consumption, projected token consumption, or the lunar phase under which those tokens were consumed.

There are excellent tools for people who want an AI usage command center.

This isn't one.

CodexReserve answers a smaller question:

> **Can I keep using Codex?**

That question deserved a two-ring answer, not another SaaS dashboard.

## Install

Requires macOS 14 or later and Codex signed in at least once. Building from source needs Xcode 26 or later.

```bash
git clone https://github.com/yourarnav/CodexReserve.git
cd CodexReserve
./install.sh
```

Then open **CodexReserve** while Codex is running.

That's the onboarding.

Don't see the ring? macOS hides new menu bar icons sometimes. Open System
Settings, go to Menu Bar, find CodexReserve, switch it on.

---

Unofficial. Not affiliated with OpenAI.

If OpenAI changes the usage endpoint, CodexReserve may break until it catches up.

MIT licensed.
