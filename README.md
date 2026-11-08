# MacBook Notch Spacer for Omarchy Shell

[![Omarchy Plugin](https://img.shields.io/badge/omarchy-shell_plugin-blue.svg)](https://omarchy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A status bar plugin for [Omarchy](https://omarchy.org/) designed specifically for Apple MacBook displays with a hardware camera notch (14" and 16" MacBook Pro, 13" and 15" MacBook Air).

---

## 🎯 The Problem

MacBooks feature a physical camera notch centered at the top of the display screen. When running Omarchy with standard bar configurations:
- Center-aligned widgets (Clock, Indicators, World Clocks) end up situated directly underneath the physical notch cutout, rendering them invisible.
- Platform display-cutout workarounds can push entire sections onto the right-side icons, causing overlap and displacement.

## ✨ The Solution

**MacBook Notch Spacer** (`wilk.macbook-notch`):
1. **Auto-Centers Under the Notch**: Automatically calculates the exact horizontal center of the display (`(windowWidth - width) / 2`) and anchors directly beneath the hardware notch with zero offset.
2. **Zero Footprint on Surrounding Icons**: Does not displace or push adjacent icons onto one another.
3. **Interactive "Dynamic Island" Settings Card**: Clicking anywhere on the notch spacer opens an interactive settings card:
   - **Live Width Slider**: Adjust spacer width in real time (60px to 360px).
   - **Hardware Presets**: 1-click presets for:
     - 14" MacBook Pro (200px)
     - 16" MacBook Pro (230px)
     - MacBook Air (180px)
     - Compact (140px)
   - **Visual Appearance Modes**: Clean transparent spacer or sleek black notch pill with curved bottom corners.
   - **Multi-Monitor Awareness**: Automatically activates on the laptop screen (`eDP-1`) and collapses cleanly when connected to an external monitor without a notch.
   - **Instant Persistence**: Saves directly to `~/.config/omarchy/shell.json` without needing shell restarts.

---

## 📦 Installation

### Option 1: Via Omarchy CLI (Recommended)

```bash
omarchy plugin add https://github.com/techt3/omarchy-macbook-notch.git --enable
```

### Option 2: Manual Git Clone

```bash
# Clone into Omarchy user plugins directory
git clone https://github.com/techt3/omarchy-macbook-notch.git ~/.config/omarchy/plugins/wilk.macbook-notch

# Rescan and enable
omarchy-shell shell rescanPlugins
omarchy plugin enable wilk.macbook-notch center
```

---

## ⚙️ Configuration

Settings are saved automatically via the interactive card or can be configured in `~/.config/omarchy/shell.json`:

```json
{
  "center": [
    {
      "id": "wilk.macbook-notch",
      "width": 200,
      "notchStyle": "spacer",
      "onlyOnNotchScreen": true
    }
  ]
}
```

### Parameters:
- `width` *(number, default: 200)*: Notch spacer width in logical pixels.
- `notchStyle` *(string, default: "spacer")*: `"spacer"` (invisible gap) or `"notch"` (black pill).
- `onlyOnNotchScreen` *(boolean, default: true)*: Only active on internal laptop screen (`eDP`).

---

## 🌍 Localization

Ships with flat translation catalogs via `qs.Commons.Translations`:
- 🇺🇸 English (`en.json`)
- 🇵🇱 Polish (`pl.json`)

---

## 📄 License

Licensed under the [MIT License](LICENSE).
