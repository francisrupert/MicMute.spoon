# MicMute.spoon

A Hammerspoon Spoon for muting/unmuting a Shure MV7 microphone with a single hotkey.

The MV7 doesn't report its mute state correctly, so this Spoon tracks the state manually. If Zoom or Microsoft Teams are running, it also syncs the mute state with them via their menu items.

## Features

- **Menubar indicator** — Shows "Muted" (red) or "ON" (green) in the macOS menu bar. Click to toggle.
- **Latch/momentary hotkey** — Quick press toggles mute. Hold and release for push-to-talk (momentary unmute/mute).
- **App sync** — Optionally syncs mute/unmute with Zoom and Microsoft Teams if they're running.

## Requirements

- [Hammerspoon](https://www.hammerspoon.org/) installed on macOS

## Installation

Copy `MicMute.spoon` to `~/.hammerspoon/Spoons/`.

## Usage

Add to your `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("MicMute")
spoon.MicMute:start()
spoon.MicMute:bindHotkeys({toggle = {{}, "f19"}})
```

### Options

`bindHotkeys` accepts an optional second argument for the latch timeout in seconds (default `0.75`):

```lua
spoon.MicMute:bindHotkeys({toggle = {{}, "f19"}}, 1.0)
```

Presses shorter than the timeout latch (toggle). Presses longer than the timeout are momentary (state reverts on release).

## API

| Method | Description |
|---|---|
| `start()` | Create the menubar item and show a load notification |
| `stop()` | Remove the menubar item and unbind the hotkey |
| `bindHotkeys(mapping, latchTimeout)` | Bind the toggle hotkey with latch/momentary behavior |
| `toggle()` | Toggle mute state and sync with running apps |

## License

MIT
