# Lib

A UI library for Roblox executors.

## Features

- Tabs, groupboxes and tabboxes, with a Horizontal or Vertical layout you can switch while the menu is open.
- Toggles, buttons, sliders, dropdowns (single, multi, searchable, players and teams), inputs, labels, key pickers and color pickers with transparency, gradients and rainbow.
- Dependency boxes that show or hide groups of elements.
- Notifications, dialogs, a watermark and a draggable keybind list.
- Works on mobile. (Full suport is not guaranteed)

## Quick start

```lua
local Repo = 'https://raw.githubusercontent.com/placeholder14331/Lib/main/'

if getgenv().Library then getgenv().Library:Unload() end

local Library = loadstring(game:HttpGet(Repo .. 'Library.luau'))()

local Window = Library:CreateWindow({ Title = 'Hub', Footer = 'v1.0', Center = true, AutoShow = true })
local Main = Window:AddTab('Main')
local Combat = Main:AddLeftGroupbox('Combat')

Combat:AddToggle('Aimbot', { Text = 'Aimbot', Default = false })
Combat:AddSlider('FOV', { Text = 'FOV', Min = 10, Max = 500, Default = 120, Rounding = 0, Suffix = 'px' })

Toggles.Aimbot:OnChanged(function()
    print('Aimbot is', Toggles.Aimbot.Value)
end)
```

To add themes and saved configs, also load the two addons:

```lua
local ThemeManager = loadstring(game:HttpGet(Repo .. 'addons/ThemeManager.luau'))()
local SaveManager = loadstring(game:HttpGet(Repo .. 'addons/SaveManager.luau'))()
```

`Example.luau` is a complete script that uses every feature. It is the quickest way to see what the library can do.

## Requirements

- An executor with `gethui` (or an alias such as `get_hidden_gui`). This is the only hard requirement.
- File functions (`writefile`, `readfile`, `isfile`, `isfolder`, `makefolder`) for saved configs, themes and preferences. Without them everything stays in memory for the session.
- `request` (or `http_request`) and `getcustomasset` to download the pixel font, tab icons and background images. Without them the font falls back to the default Roblox `Code` font.

## License

MIT. See [LICENSE](LICENSE).
