# CodexBar

Your Codex limits. In the menu bar.

<p align="center">
  <img src="screenshot-popover-v2.png" alt="CodexBar" width="300" />
</p>

I kept checking how much Codex I had left.

So I put it in the menu bar.

That's CodexBar.

Your **5-hour limit** and your **weekly limit**, always there when Codex is running. Hover to see the details. It refreshes itself. A quiet chime lets you know when you're getting low.

Nothing else.

## Built for this

CodexBar isn't trying to become an AI dashboard.

It doesn't need every provider, every model, token history, spend analytics, charts, forecasts, accounts, sync, or a settings page for configuring the settings page.

Those are real products. This is a different thing.

I wanted to know how much Codex I had left without going anywhere to find out.

Now I can.

## Native Mac app

Written in Swift.

**SwiftUI + AppKit. Zero dependencies.**

No Electron. No web view. No local server. No Dock icon.

It uses the Codex authentication already on your Mac, checks your usage once a minute, and otherwise stays out of the way.

Quit Codex and CodexBar quits with it.

It knows when its job is done.

## Install

Requires macOS 14 or later and Codex signed in at least once. Building from source needs Xcode 26 or later. Command Line Tools are enough.

```bash
git clone https://github.com/yourarnav/CodexBar.git
cd CodexBar
./install.sh
```

Open Codex. Open CodexBar.

That's the setup.

## Why only Codex?

Because that's what I wanted.

There isn't a roadmap to turn this into everything.

If I wanted a dashboard, I would have built a dashboard.

I wanted a meter.

So I built a good one.

---

Free and open source.

Unofficial. Not affiliated with OpenAI.

MIT.
