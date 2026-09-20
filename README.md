<h1 align="center">CodexReserve</h1>

<p align="center">
  <a href="https://github.com/yourarnav/CodexReserve/releases">
    <img
      src="https://img.shields.io/github/downloads/yourarnav/CodexReserve/CodexReserve.dmg?label=Downloads&logo=github&displayAssetName=false&labelColor=24292f&color=2f81f7"
      alt="CodexReserve Downloads"
    />
  </a>
  <a href="https://youtube.com/shorts/rkSRLMNiIJk">
    <img
      src="https://img.shields.io/badge/YouTube-12s%20Demo-FF0000?logo=youtube&logoColor=white"
      alt="Watch Demo on YouTube"
    />
  </a>
</p>

<p align="center">
  <img
    src="docs/screenshot-popover-v2.png"
    alt="CodexReserve showing Codex usage limits"
    width="300"
  />
</p>

<p align="center">
  <a href="https://youtube.com/shorts/rkSRLMNiIJk"><strong>▶ Watch 12s Demo</strong></a>
</p>


<p align="center">
  <strong>Look up. Know if you can keep coding. Continue with your life.</strong>
</p>

## Get it

One command, no building:

```bash
brew install --cask yourarnav/tap/codexreserve
```

Prefer the manual way? Grab `CodexReserve.dmg` from
[Releases](https://github.com/yourarnav/CodexReserve/releases),
open it, and drag **CodexReserve** into Applications.

The code is all on this page. Go read it first if you like.

### First launch

Your Mac may call the app damaged because CodexReserve is free, self-signed,
and not notarized.

Clear the quarantine flag once:

```bash
xattr -dr com.apple.quarantine /Applications/CodexReserve.app
```

Then open it normally.

That warning is the price of free.

## It does one job

The **green ring** is your 5-hour Codex limit.

The **blue ring** is your weekly limit.

Pro accounts with no 5-hour window show the weekly ring solo. The app
shows whatever windows your account actually has.

Hover for the numbers and reset times.

CodexReserve refreshes quietly in the background and gives you a chime
as your limits run down.

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

CodexReserve does not track Claude, Gemini, OpenRouter, your local llama farm,
API spend, historical token consumption, projected token consumption, or the
lunar phase under which those tokens were consumed.

There are excellent tools for people who want an AI usage command center.

This isn't one.

CodexReserve answers a smaller question:

> **Can I keep using Codex?**

That question deserved a two-ring answer, not another SaaS dashboard.

## Install from source

Requires **macOS 14 or later** and Codex signed in at least once.

Building from source requires **Xcode 26 or later**.

```bash
git clone https://github.com/yourarnav/CodexReserve.git
cd CodexReserve
./install.sh
```

Then open **CodexReserve** while Codex is running.

That's the onboarding.

### Don't see the ring?

macOS hides new menu bar icons sometimes.

Open **System Settings → Menu Bar**, find **CodexReserve**, and switch it on.

---

<p align="center">
  Unofficial. Not affiliated with OpenAI.
</p>

<p align="center">
  If OpenAI changes the usage endpoint, CodexReserve may break until it catches up.
</p>

<p align="center">
  MIT licensed.
</p>
