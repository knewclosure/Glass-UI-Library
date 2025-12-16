# Luminescent UI Library

A modern **glass‑style Roblox UI library** featuring animated loading screens, tabs, toggles, sliders, notifications, and smooth transitions. Designed for exploit or local execution environments with automatic CoreGui / PlayerGui handling.

---

## 📌 Table of Contents

1. Overview
2. Environment & Requirements
3. Loading / Referencing the Library
4. Creating a Window
5. Loading Screen System
6. Tabs
7. UI Elements (Controls)

   * Label
   * Button
   * Toggle
   * Slider
   * Number Input
8. Notification System
9. Window Controls & Keybinds
10. Example Script (Full)
11. Notes & Best Practices

---

## 1️⃣ Overview

**Luminescent UI** provides:

* Matte dark glass aesthetic
* Animated breathing strokes & glow
* Built‑in loading screen with blur
* Notification popups
* Tabbed layout with scrolling content
* Keyboard toggle (`U`) and draggable window

The library automatically parents itself to **CoreGui** when permitted, falling back to **PlayerGui** if not.

---

## 2️⃣ Environment & Requirements

* Must be executed from a **LocalScript or exploit executor**
* Requires access to:

  * `UserInputService`
  * `TweenService`
  * `RunService`
* Designed for **client‑side UI only**

⚠️ This library is **not server‑replicated** and should never be used in server scripts.

---

## 3️⃣ Loading / Referencing the Library

### 🔹 Remote load (typical usage)

```lua
local Library = loadstring(game:HttpGet("<RAW_LIBRARY_URL>"))()
```

### 🔹 Local module usage

```lua
local Library = require(path.to.Library)
```

The returned value is a **Library object** exposing all public API methods.

---

## 4️⃣ Creating a Window

```lua
local Window = Library:CreateWindow("My Script Title")
```

### What this does:

* Creates the loading screen (hidden initially)
* Creates the main UI window (disabled initially)
* Sets up notifications
* Registers the `U` keybind for toggling visibility

### Returned Object: `Window`

Contains:

* `Window:CreateTab(name)`
* `Window:StartLoadScreen(time)`
* `Window:CreateNotification(title, msg, duration)`

---

## 5️⃣ Loading Screen System

### Start the loading animation

```lua
Window:StartLoadScreen(3) -- seconds
```

Behavior:

* Progress bar fills over `loadTime`
* Screen blur fades out
* Main UI fades in
* Loading GUI is destroyed automatically

💡 Call this **after** creating tabs/elements but **before** user interaction.

---

## 6️⃣ Tabs

### Create a tab

```lua
local MainTab = Window:CreateTab("Main")
```

* First tab is automatically selected
* Tabs are displayed horizontally
* Each tab has its own scrolling content container

Returned object (`Tab`) is used to create UI elements.

---

## 7️⃣ UI Elements (Controls)

All UI elements are created **on a Tab object**.

---

### 🔹 Label

```lua
MainTab:CreateLabel("Status: Ready")
```

Static text label (non‑interactive).

---

### 🔹 Button

```lua
MainTab:CreateButton("Execute", function()
    print("Button clicked")
end)
```

* One‑shot pulse animation on click
* Hover highlight

---

### 🔹 Toggle

```lua
MainTab:CreateToggle("God Mode", false, function(state)
    print("God Mode:", state)
end)
```

Parameters:

1. `text` – label text
2. `default` – boolean
3. `callback(state)` – fires on toggle

Visual behavior:

* Green glow when enabled
* Dimmed grey when disabled

---

### 🔹 Slider

```lua
MainTab:CreateSlider("Speed", 10, 100, 25, function(value)
    print("Speed set to", value)
end)
```

Parameters:

1. `text`
2. `min`
3. `max`
4. `default`
5. `callback(value)`

* Click or drag to change value
* Live update
* Animated glow follows slider head

---

### 🔹 Number Input

```lua
MainTab:CreateNumberInput("Jump Power", 50, 200, 100, function(value)
    print("Jump Power:", value)
end)
```

Parameters:

1. `text`
2. `min` (optional, default 0)
3. `max` (optional, default 100)
4. `default`
5. `callback(value)`

Behavior:

* Manual numeric input
* Auto‑clamped
* Reverts if invalid text

---

## 8️⃣ Notification System

```lua
Window:CreateNotification(
    "Success",
    "Script loaded successfully",
    3
)
```

Parameters:

1. `title`
2. `message`
3. `duration` (seconds, optional)

Features:

* Top‑right stacking
* Slide‑in animation
* Dramatic fade/shatter exit

Notifications are fully independent of tabs.

---

## 9️⃣ Window Controls & Keybinds

### 🔹 Keyboard Toggle

* **Press `U`** to show/hide the UI

### 🔹 Window Buttons

* ❌ Close: hides UI
* ➖ Minimize: collapses into title bar

### 🔹 Dragging

* Drag the **title bar** (when not minimized)

---

## 🔟 Full Example Script

```lua
local Library = loadstring(game:HttpGet("<RAW_LIBRARY_URL>"))()

local Window = Library:CreateWindow("Luminescent Demo")

local Tab = Window:CreateTab("Main")

Tab:CreateLabel("Welcome")

Tab:CreateToggle("ESP", false, function(v)
    print("ESP", v)
end)

Tab:CreateSlider("WalkSpeed", 16, 100, 16, function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
end)

Tab:CreateNumberInput("JumpPower", 50, 200, 100, function(v)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
end)

Tab:CreateButton("Notify", function()
    Window:CreateNotification("Hello", "This is a test", 3)
end)

Window:StartLoadScreen(2)
```

---

## 1️⃣1️⃣ Notes & Best Practices

* Create **all tabs & elements before** calling `StartLoadScreen`
* Keep callbacks lightweight to avoid UI lag
* Avoid spawning UI elements dynamically inside fast loops
* This library is **client‑only** and should not be used for secure logic

---

## ✅ Summary

Luminescent UI offers:

* Clean API
* Modern visuals
* Smooth animations
* Minimal setup

Perfect for tools, panels, hubs, and script menus.

---

**End of Documentation**
