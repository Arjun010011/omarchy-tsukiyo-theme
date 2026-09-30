-- Tsukiyo for Neovim, built on tokyonight's highlight coverage.
-- Philosophy: text is parchment, structure is slate, colour is spent sparingly.
-- Keywords and functions carry the hue; punctuation, comments and chrome recede.
return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = false },
        functions = {},
        variables = {},
        sidebars = "dark",
        floats = "dark",
      },
      dim_inactive = false,
      lualine_bold = false,

      on_colors = function(c)
        -- Surfaces: the castle's night ink, one step apart each
        c.bg = "#121820"
        c.bg_dark = "#0e1319"
        c.bg_dark1 = "#0a0e13"
        c.bg_float = "#0e1319"
        c.bg_sidebar = "#0e1319"
        c.bg_popup = "#0e1319"
        c.bg_statusline = "#0e1319"
        c.bg_highlight = "#1a222b"
        c.bg_visual = "#243039"
        c.bg_search = "#2b3a44"

        -- Text
        c.fg = "#c8c4bb"
        c.fg_dark = "#b3b0a8"
        c.fg_float = "#c8c4bb"
        c.fg_sidebar = "#b3b0a8"
        c.fg_gutter = "#2e3a43"
        c.comment = "#5f6e76"
        c.dark3 = "#4a5a63"
        c.dark5 = "#6a7175"
        c.terminal_black = "#243039"
        c.border = "#1a222b"
        c.border_highlight = "#4a5a63"

        -- Hue, all at the same low saturation
        c.blue = "#7a98ab"
        c.blue0 = "#243039"
        c.blue1 = "#88a4ad"
        c.blue2 = "#7fa3a3"
        c.blue5 = "#89a6b8"
        c.blue6 = "#a9c0c6"
        c.blue7 = "#2b3a44"
        c.cyan = "#7fa3a3"
        c.teal = "#7fa3a3"
        c.green = "#8ca483"
        c.green1 = "#88a4ad"
        c.green2 = "#6f8a80"
        c.yellow = "#c4b48a"
        c.orange = "#b8977a"
        c.red = "#b37a72"
        c.red1 = "#b37a72"
        c.magenta = "#9c8898"
        c.magenta2 = "#aa97a6"
        c.purple = "#9c8898"

        c.git = { add = "#6f8a68", change = "#6a8594", delete = "#9a6760" }
        c.diff = { add = "#18231c", change = "#162029", delete = "#261a1b", text = "#223340" }
        c.error = "#b37a72"
        c.warning = "#c4b48a"
        c.info = "#7a98ab"
        c.hint = "#7fa3a3"
      end,

      on_highlights = function(hl, c)
        local mist = "#88a4ad"

        -- Editor chrome: nearly invisible until you need it
        hl.LineNr = { fg = "#2e3a43" }
        hl.LineNrAbove = { fg = "#2e3a43" }
        hl.LineNrBelow = { fg = "#2e3a43" }
        hl.CursorLineNr = { fg = mist }
        hl.CursorLine = { bg = "#161d26" }
        hl.SignColumn = { bg = c.bg }
        hl.WinSeparator = { fg = "#1a222b" }
        hl.VertSplit = { fg = "#1a222b" }
        hl.EndOfBuffer = { fg = c.bg }
        hl.NonText = { fg = "#2e3a43" }
        hl.Whitespace = { fg = "#1f2831" }
        hl.MatchParen = { fg = c.yellow, bold = true }
        hl.Visual = { bg = "#243039" }
        hl.Search = { bg = "#2b3a44", fg = c.fg }
        hl.IncSearch = { bg = mist, fg = c.bg }
        hl.CurSearch = { bg = mist, fg = c.bg }

        -- Floats and popups share one framed look
        hl.NormalFloat = { bg = c.bg_float, fg = c.fg }
        hl.FloatBorder = { bg = c.bg_float, fg = "#2e3a43" }
        hl.FloatTitle = { bg = c.bg_float, fg = mist }
        hl.Pmenu = { bg = c.bg_float, fg = c.fg_dark }
        hl.PmenuSel = { bg = "#243039", fg = c.fg }
        hl.PmenuSbar = { bg = c.bg_float }
        hl.PmenuThumb = { bg = "#2e3a43" }

        -- Syntax
        hl.Comment = { fg = c.comment, italic = true }
        hl["@comment"] = { link = "Comment" }
        hl["@punctuation.bracket"] = { fg = "#8a9095" }
        hl["@punctuation.delimiter"] = { fg = "#6a7175" }
        hl["@operator"] = { fg = "#8a9095" }
        hl["@keyword"] = { fg = c.magenta }
        hl["@keyword.function"] = { fg = c.magenta }
        hl["@keyword.return"] = { fg = c.magenta }
        hl["@function"] = { fg = c.blue }
        hl["@function.call"] = { fg = c.blue }
        hl["@function.method.call"] = { fg = c.blue }
        hl["@variable"] = { fg = c.fg }
        hl["@variable.member"] = { fg = "#b3b0a8" }
        hl["@property"] = { fg = "#b3b0a8" }
        hl["@variable.parameter"] = { fg = "#c8b9a4", italic = true }
        hl["@type"] = { fg = c.cyan }
        hl["@type.builtin"] = { fg = c.cyan }
        hl["@constant"] = { fg = c.orange }
        hl["@constant.builtin"] = { fg = c.orange }
        hl["@number"] = { fg = c.orange }
        hl["@boolean"] = { fg = c.orange }
        hl["@string"] = { fg = c.green }
        hl["@string.escape"] = { fg = c.cyan }
        hl["@tag"] = { fg = c.blue }
        hl["@tag.attribute"] = { fg = c.cyan, italic = true }
        hl["@tag.delimiter"] = { fg = "#6a7175" }
        hl["@markup.heading"] = { fg = mist, bold = true }
        hl["@markup.link"] = { fg = c.cyan, underline = true }

        -- Diagnostics: soft undercurls, tinted virtual text
        hl.DiagnosticVirtualTextError = { fg = c.red, bg = "#1c1a1f" }
        hl.DiagnosticVirtualTextWarn = { fg = c.yellow, bg = "#1b1d1e" }
        hl.DiagnosticVirtualTextInfo = { fg = c.blue, bg = "#151e27" }
        hl.DiagnosticVirtualTextHint = { fg = c.cyan, bg = "#151f24" }

        -- File trees and pickers
        hl.Directory = { fg = c.blue }
        hl.SnacksPickerDir = { fg = c.comment }
        hl.SnacksPickerFile = { fg = c.fg }
        hl.SnacksPickerMatch = { fg = mist, bold = true }
        hl.SnacksPickerPrompt = { fg = mist }
        hl.SnacksPickerTitle = { fg = c.bg, bg = mist }
        hl.SnacksPickerBorder = { fg = "#2e3a43", bg = c.bg_float }
        hl.SnacksExplorerDirectory = { fg = c.blue }
        hl.SnacksIndent = { fg = "#1c242d" }
        hl.SnacksIndentScope = { fg = "#34424c" }
        hl.SnacksDashboardHeader = { fg = mist }
        hl.SnacksDashboardKey = { fg = c.yellow }
        hl.SnacksDashboardIcon = { fg = c.blue }
        hl.SnacksDashboardDesc = { fg = c.fg_dark }
        hl.SnacksDashboardFooter = { fg = c.comment, italic = true }
        hl.NeoTreeDirectoryName = { fg = c.blue }
        hl.NeoTreeDirectoryIcon = { fg = c.blue }
        hl.NeoTreeRootName = { fg = mist, bold = true }
        hl.NvimTreeFolderName = { fg = c.blue }
        hl.NvimTreeFolderIcon = { fg = c.blue }
        hl.TelescopeBorder = { fg = "#2e3a43", bg = c.bg_float }
        hl.TelescopeMatching = { fg = mist, bold = true }
        hl.TelescopeSelection = { bg = "#243039", fg = c.fg }
        hl.TelescopePromptTitle = { fg = c.bg, bg = mist }
        hl.MiniFilesTitleFocused = { fg = mist, bold = true }
        hl.MiniIndentscopeSymbol = { fg = "#34424c" }
        hl.IblIndent = { fg = "#1c242d" }
        hl.IblScope = { fg = "#34424c" }

        -- Completion menu kinds stay in the same quiet family
        hl.BlinkCmpMenuBorder = { fg = "#2e3a43", bg = c.bg_float }
        hl.BlinkCmpDocBorder = { fg = "#2e3a43", bg = c.bg_float }
        hl.BlinkCmpLabelMatch = { fg = mist, bold = true }

        -- Which-key, noice, notify
        hl.WhichKey = { fg = mist }
        hl.WhichKeyGroup = { fg = c.blue }
        hl.WhichKeyDesc = { fg = c.fg_dark }
        hl.WhichKeySeparator = { fg = "#4a5a63" }
        hl.NoiceCmdlinePopupBorder = { fg = "#2e3a43" }
        hl.NoiceCmdlineIcon = { fg = mist }

        -- Statusline mode colours: one mist accent, varied only by mode
        hl.lualine_a_normal = { fg = c.bg, bg = mist }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
