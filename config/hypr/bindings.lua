-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
-- omarchy_preinstalled_bindings = false

local mainMod = "SUPER"

hl.unbind(mainMod .. " + W")
o.bind(mainMod .. " + Q", "Close window", hl.dsp.window.close())

local motions = {
  { key = "h", dir = "left",  mov = "left" },
  { key = "j", dir = "down",  mov = "below" },
  { key = "k", dir = "up",    mov = "above" },
  { key = "l", dir = "right", mov = "right" },
}

for _, motion in pairs(motions) do
  hl.unbind("SUPER + " .. motion.key)         -- unbind mod + hjkl
  hl.unbind("SUPER + " .. motion.dir)         -- unbind mod + arrow keys
  hl.unbind("SUPER + SHIFT + " .. motion.dir) -- unbind mod shift + arrow keys
  o.bind(
    mainMod .. " + " .. string.upper(motion.key),
    "Focus on " .. motion.mov .. " window",
    hl.dsp.focus({ direction = motion.dir })
  )
  o.bind(
    mainMod .. " + SHIFT + " .. string.upper(motion.key),
    "Swap window " .. motion.mov,
    hl.dsp.window.swap({ direction = motion.dir })
  )
end

hl.unbind("SUPER + SHIFT + SLASH")
o.bind(mainMod .. " + SHIFT + SLASH", "Keybindings", "omarchy-menu-keybindings")

o.bind(mainMod .. " + ALT + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
