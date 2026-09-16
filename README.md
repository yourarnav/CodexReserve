# CodexReserve


<p align="center">
  <img src="docs/screenshot-popover-v2.png" alt="CodexReserve showing Codex usage limits" width="300" />
</p>

Look up. Know if you can keep coding. Continue with your life.

## Get it

No building needed. Grab `CodexReserve.dmg` from
[Releases](https://github.com/yourarnav/CodexReserve/releases),
open it, drag CodexReserve into Applications. The code is all on this page,
go read it first if you like.

First launch: right-click CodexReserve, choose Open. Your Mac warns about
unknown developers because this is free and self signed, not notarized.
That warning is the price of free.

## It does one job

The **green ring** is your 5-hour Codex limit.

The **blue ring** is your weekly limit.

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

---

Unofficial. Not affiliated with OpenAI.

If OpenAI changes the usage endpoint, CodexReserve may break until it catches up.

MIT licensed.
