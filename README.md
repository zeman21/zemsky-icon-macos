# PixelMate

A lightweight pixel cat that lives on your macOS desktop. Transparent, always on top, click-through everywhere except the cat itself. Built with Tauri 2 + Rust, with a React/Tailwind settings window and a plain-TypeScript Canvas 2D renderer. Fully offline.

- Menu bar app (no Dock icon), draggable, remembers its position, multi-monitor aware
- 14 animated states driven by a priority-based state machine (idle, blink, walk, run, sit, sleep, look, typing, jump, happy, thinking, drag, drop, error)
- Reacts to mouse (looks at the cursor, jumps on click, optional cursor-follow) and keyboard (types along, gets excited when you type fast)
- Bring your own sprites (transparent PNG or sprite sheet + JSON), no source edits
- Optional AI-agent awareness through a local-only endpoint

## Install

**From a DMG** – open `PixelMate_0.1.0_universal.dmg`, drag PixelMate to Applications, launch it.
Builds from this repo are ad-hoc signed, not notarized. If Gatekeeper blocks a *downloaded* copy: right-click → Open, or
`xattr -dr com.apple.quarantine /Applications/PixelMate.app`.

**Homebrew (custom tap)** – after you publish a release, see `Casks/pixelmate.rb`:

```bash
brew tap YOUR_GITHUB_USER/pixelmate
brew install --cask pixelmate
```

## Develop

Requirements: macOS 11+, Node 18+, Rust (stable), Xcode Command Line Tools.

```bash
npm install
npm run tauri dev      # run the app
npm test               # vitest: state machine + sprite config
(cd src-tauri && cargo test)
npm run tauri build    # PixelMate.app + DMG in src-tauri/target/release/bundle/
npm run release        # same, and prints the sha256 for the Homebrew cask
npm run assets         # regenerate the default cat, app icon and tray icon
```

Relaunching the app (Finder/Spotlight) opens Settings. The menu bar icon has Show/Hide, Always on Top, Jump, Reset Position, Settings and Quit.

## Permissions

| Feature | Permission | Notes |
|---|---|---|
| Mouse look / click-through | none | Event-driven global mouse-move monitor |
| Typing reaction | **Input Monitoring** | Only *that* a key was pressed is observed; key codes and characters are never read, stored or sent. Grant it in Settings → Behavior → Keyboard. If you skip it, everything else still works. |
| Launch at login | none | Uses a LaunchAgent |
| AI integration | none | Listens on `127.0.0.1` only, and only while enabled |

## Speech bubbles & reminders

Settings → **Notifications**. The character talks through pixel-style speech bubbles (Bahasa Indonesia or English):

- **Reminders** – drink water, eye rest (20-20-20), posture, stretch, lunch, bedtime, plus any custom ones (repeat every N minutes, or daily at a time). Reminders have *Later 10m* / *OK* buttons, wait for a pause while you are typing, and are held back during **quiet hours**.
- **Extras** – time-of-day greeting, welcome back after a long break, random chatter, "Geli ih!" when poked / "purr~" when petted, agent updates (done / error / needs you), and a break suggestion after ~45 min of non-stop typing (only key *counts* are used).
- Optional 8-bit blip sound. Everything is driven by a single timer armed for the next due item, so there is no polling.

## Focus timer (Pomodoro)

Settings → **Focus** or menu bar → *Start / Stop Focus*. The character works at its laptop while the 🍅 badge counts down under it, then cheers when it is time to rest. Durations, sessions per round and the badge are configurable.

## Calendar alerts (Outlook, Google, iCloud)

Settings → **Calendar**: paste a published **.ics link** and the character tells you before meetings (with a **Join** button for Teams / Zoom / Meet links). Recurring meetings, time zones (including Outlook's Windows zone names), exceptions and cancellations are handled. For Outlook on the web: Settings → Calendar → Shared calendars → *Publish a calendar* → copy the ICS link. Work/school accounts often have publishing disabled by an admin. Feeds are fetched by the app only (every 15 min, https only) and treated like a password. Reading Apple Calendar / Exchange accounts directly (EventKit) is not implemented.

## Bond & accessories

Daily visits, finished focus sessions, acknowledged reminders, finished agent tasks and petting earn XP (with daily caps). Levels unlock accessories (bow, glasses, scarf, crown) that are drawn on the bundled characters.

## Bundled characters and sharing

Cat, Kuro, Shiro, Abu, Bunny and Puppy ship with the app. Export your own character as a single `.pixelmate` file and import one from a friend (Settings → Character → Share).

Clicking an agent's result bubble (marked ↗) brings the terminal / editor that ran it to the front.

## Known limits

- The universal build (Apple Silicon + Intel) is built, but only the Apple Silicon half has been run on a real Mac; not notarized (see the Gatekeeper note above).
- Notarization and auto-update need an Apple Developer ID and signing keys that this repo does not contain.
- Display hot-plug and fullscreen-Space visibility are implemented but only verified by compiling, not on multiple monitors.

## Custom characters

**Import does the cleanup for you** (Settings → Character → *Import PNG…*; both steps can be switched off):

1. **Clean up** – removes a solid background by flood-filling from the border (white eyes etc. inside the subject are kept, and background trapped between the legs is cleared), detects pixel art that was enlarged by an integer factor and restores the native pixels so it stays crisp, and shrinks other large images smoothly.
2. **Animate** – a single still image gets a full generated animation set (breathing, waddle, run, jump, squash, sleep, hearts, …) using pixel-exact squash/stretch, lean and lift. Sprite sheets are split into frames automatically and left as-is.

The original is kept, so *Re-process* can redo it with different options.

Settings → Character → **Import PNG…** copies your image to
`~/Library/Application Support/com.pixelmate.app/characters/<id>/` as `sheet.png` + `sprite.json`. Set the frame size, use *Auto-split rows* or define animations, and map them to states. You can also drop your own folder there. `sprite.json`:

```json
{
  "name": "My Pet",
  "frameWidth": 32,
  "frameHeight": 32,
  "animations": {
    "idle": { "start": 0, "count": 2, "fps": 3, "loop": true },
    "walk": { "start": 8, "count": 4, "fps": 8 },
    "peek": { "frames": [3, 2, 3, 4], "fps": 4 }
  },
  "states": { "idle": "idle", "walk": "walk", "look": "peek" }
}
```

Frames are numbered left-to-right, top-to-bottom. Sprites should face **right** (the app mirrors them). Any state without a mapping falls back to the animation with the same name, then `idle`; `blink` is skipped if absent. The default cat is generated by `tools/make-assets.mjs`.

## AI coding agents

**Fastest way:** Settings → AI Integration → *Connect your tools*. One click installs (and removes) the hooks for Claude Code, Cursor, Codex and OpenCode, and a zsh integration for **any command** (builds, tests, scripts, and agents without hooks such as Antigravity). Config files are backed up (`*.bak-pixelmate-<time>`), existing hooks are kept, and installing twice never duplicates entries.

| Pet reaction | Meaning |
|---|---|
| thinking pose | agent got your prompt |
| typing on a laptop | running tools / commands |
| looking around + bubble | waiting for your permission / input |
| happy + hearts + bubble "(2m 14s)" | finished |
| sad + sweat drop | failed |

Wrap any command by hand with `pixelmate-run npm test` (it keeps the command's exit code). The terminal integration stays silent for commands under 5 s and for interactive programs (vim, ssh, claude, …).

Manual setup details:

Enable Settings → AI Integration. PixelMate then listens on `127.0.0.1:47321` for events and maps normalized states to animations: thinking → thinking, working → typing, waiting → looking around, completed → happy, error → sad. Settings has copy-paste setup snippets and a **Test animation** simulator.

Send events with the helper (written to `~/Library/Application Support/com.pixelmate.app/bin/pixelmate-notify`) or plain HTTP:

```bash
curl -X POST "http://127.0.0.1:47321/event?agent=custom&state=thinking"
```

The integrations are **not equivalent**, because the tools expose different things:

| Agent | Mechanism | What you get |
|---|---|---|
| Claude Code | [hooks](https://docs.claude.com/en/docs/claude-code/hooks) in `~/.claude/settings.json` | thinking, working, waiting, completed |
| OpenAI Codex CLI | `notify` in `~/.codex/config.toml` | completion only |
| Cursor | [hooks.json](https://cursor.com/docs/agent/hooks) | prompt submitted, file edited, stop; behavior varies by version |
| OpenCode | plugin in `~/.config/opencode/plugins/` | session idle/error and tool use (event names from its plugin docs) |
| Google Antigravity | none that I could verify | use the generic endpoint or simulator |

Snippets for Cursor, OpenCode and Codex were written from documentation, not tested against live installs of those tools; check each tool's current docs if something doesn't fire.

## Architecture

```
src-tauri/src
  lib.rs         windows, tray, commands, applying settings
  input.rs       NSEvent global monitors (mouse, key count) + Input Monitoring check
  agents.rs      127.0.0.1 listener, event normalization
  characters.rs  user sprite storage and validation
  settings.rs    JSON settings (settings.json in the app config dir)
src/pet          renderer: fsm.ts (priority state machine), sprite.ts, pet.ts
src/settings     React settings UI
```

The pet window covers one monitor, is transparent, and ignores the mouse except while the cursor is over an opaque sprite pixel. Movement is a CSS transform snapped to device pixels, so the sprite is never smoothed. Timers wake only for the next sprite frame or state expiry; a render loop only runs while moving, jumping or dragging; hiding the character stops everything.
