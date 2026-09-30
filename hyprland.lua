-- Ink & mist: quiet borders, soft shadows, and slow, eased motion.
-- Note: `omarchy theme install` drops this file and regenerates the borders
-- from colors.toml, so the gradient lives there too. Everything below is a
-- bonus for people who apply the theme from a local copy.

local active_border_color = { colors = { "rgba(88a4adee)", "rgba(8ca48399)" }, angle = 45 }
local inactive_border_color = "rgba(28323aaa)"

hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 14,
    border_size = 2,
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
    resize_on_border = false,
    allow_tearing = false,
  },

  decoration = {
    rounding = 14,
    rounding_power = 2.4,

    active_opacity = 1.0,
    inactive_opacity = 0.97,
    fullscreen_opacity = 1.0,

    -- A faint veil over unfocused windows, like mist in the castle valley.
    dim_inactive = true,
    dim_strength = 0.06,
    dim_special = 0.35,

    shadow = {
      enabled = true,
      range = 26,
      render_power = 4,
      color = "rgba(0a0e1399)",
      color_inactive = "rgba(0a0e1344)",
      offset = "0 6",
      scale = 1.0,
    },

    blur = {
      enabled = true,
      size = 10,
      passes = 3,
      contrast = 0.95,
      brightness = 0.9,
      vibrancy = 0.12,
      vibrancy_darkness = 0.2,
      noise = 0.02,
      ignore_opacity = true,
      new_optimizations = true,
      xray = false,
      popups = true,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
    groupbar = {
      gradients = true,
      gradient_rounding = 10,
      gradient_round_only_edges = true,
      col = {
        active = "rgba(88a4ad44)",
        inactive = "rgba(1a222bcc)",
      },
      text_color = "rgb(c8c4bb)",
    },
  },

  animations = {
    enabled = true,
  },

  misc = {
    animate_manual_resizes = true,
    animate_mouse_windowdragging = false,
    background_color = "rgb(0a0e13)",
  },
})

-- Frost the translucent shell surfaces: the bar, the island, and the popups,
-- menus and notifications that open from them.
hl.layer_rule({ match = { namespace = "^(omarchy-bar|dynamic-island)$" }, blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ match = { namespace = "^omarchy-(menu|clipboard|emojis|notifications|osd|polkit|reminders|keyboard-panel)$" }, blur = true, ignore_alpha = 0.5 })

-- Curves: everything decelerates gently; nothing bounces.
hl.curve("inkOut", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })      -- easeOutExpo-ish
hl.curve("inkSoft", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1 } } })   -- ease
hl.curve("inkRise", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })     -- easeOutQuint
hl.curve("inkSettle", { type = "bezier", points = { { 0.34, 1.2 }, { 0.64, 1 } } }) -- tiny overshoot
hl.curve("inkFade", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })
hl.curve("inkLinear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

-- Windows surface from the mist: a small grow plus fade, and sink back out.
hl.animation({ leaf = "windows", enabled = true, speed = 4.5, bezier = "inkRise" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.2, bezier = "inkSettle", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.6, bezier = "inkFade", style = "popin 94%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4.5, bezier = "inkOut", style = "slide" })

-- Focus: the border colour glides over, and the gradient turns a quarter.
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "inkOut" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "inkSoft" })

hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "inkSoft" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 3.2, bezier = "inkFade" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.6, bezier = "inkFade" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 4, bezier = "inkSoft" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 4, bezier = "inkSoft" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 3, bezier = "inkSoft" })

-- Workspaces drift sideways a little and cross-fade, rather than a full-screen slide.
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "inkOut", style = "slidefade 12%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3.8, bezier = "inkOut", style = "slidefadevert 18%" })

-- Bar, launcher, notifications: fade in while growing the last few percent.
hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "inkOut", style = "fade" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "inkOut", style = "popin 96%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2.6, bezier = "inkFade", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 3, bezier = "inkFade" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.4, bezier = "inkFade" })

hl.animation({ leaf = "zoomFactor", enabled = true, speed = 5, bezier = "inkOut" })
