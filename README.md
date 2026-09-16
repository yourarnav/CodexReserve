# CodexBar

Two rings in your menu bar.

**5-hour limit. Weekly limit. That’s it.**

<p align="center">
  <img src="screenshot-popover-v2.png" alt="CodexBar showing Codex usage limits" width="300" />
</p>

Look up. Know if you can keep coding. Continue with your life.

## It does one job

The **green ring** is your 5-hour Codex limit.

The **blue ring** is your weekly limit.

Hover for the numbers and reset times.

CodexBar refreshes quietly in the background and gives you a chime as your limits run down.

No dashboard to maintain.
No account to create.
No provider to configure.

## Built like a Mac app

CodexBar is native Swift.

**SwiftUI + AppKit. Zero dependencies.**

No Electron.
No web view wearing a `.app` costume.
No local server.
No background process reconsidering its purpose six hours after you stopped coding.

## Deliberately not everything

CodexBar does not track Claude, Gemini, OpenRouter, your local llama farm, API spend, historical token consumption, projected token consumption, or the lunar phase under which those tokens were consumed.

There are excellent tools for people who want an AI usage command center.

This isn't one.

CodexBar answers a smaller question:

> **Can I keep using Codex?**

That question deserved a two-ring answer, not another SaaS dashboard.

## Install

Requires macOS 14 or later and Codex signed in at least once. Building from source needs Xcode 26 or later.

```bash
git clone https://github.com/yourarnav/CodexBar.git
cd CodexBar
./install.sh
```

Then open **CodexBar** while Codex is running.

That's the onboarding.

---

Unofficial. Not affiliated with OpenAI.

If OpenAI changes the usage endpoint, CodexBar may break until it catches up.

MIT licensed.
