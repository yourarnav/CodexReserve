# CodexBar

Two numbers. Your menu bar. That is the whole app.

<p align="center">
  <img src="screenshot-popover-v2.png" alt="Popover: double rings, limits, resets" width="300" />
</p>

Codex gives you two limits: five hours, and a week. CodexBar puts both in your menu bar and gets out of the way.

## Why this exists

Other limit trackers wanted to be your copilot. 69 providers. Token counters. Spend charts. Burn down charts. A SQLite database of your last 25,000 sessions. Widgets. A CLI. A Raycast extension. READMEs in seven languages. Confetti when your quota resets. Confetti.

CodexBar shows two rings. Blue is the week. Green is the next five hours. When either runs low, a chime tells you before Codex does. Then it quits with Codex and leaves no trace, like a good guest.

## Run it

You need macOS 14 or later, Xcode 26 or later, and Codex signed in once.

```bash
git clone https://github.com/yourarnav/CodexBar.git
cd CodexBar
./install.sh
```

Open Codex, then open CodexBar from Launchpad. Quit Codex and it quits with it. Nothing starts at login. Ever.

## How it works

It reads your local `~/.codex/auth.json` and asks OpenAI's usage endpoint how much you have left, once a minute. Nothing else leaves your Mac. Unofficial project, not affiliated with OpenAI. If they move the endpoint, this breaks until someone moves it back.

## Fine print

17 MB of RAM. About 0.1% CPU. Zero dependencies. MIT licensed, so do whatever you want with it.
