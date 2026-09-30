# Tsukiyo for the Tide prompt.
# Tide renders from universal variables, so this recolours them in place. It
# only translates known Catppuccin Mocha values (Tide's most common palette) to
# their Tsukiyo counterparts, so any prompt layout keeps working. Named zz-
# so it runs after other conf.d files that set Tide's colours at startup.
# Delete this file (and restart fish) to let those files restore their colours.

status is-interactive; or exit
set -q tide_left_prompt_items; or exit

set -l tsukiyo_map \
    313244:1f2c2b 45475a:28323a 585b70:4a5a63 1e1e2e:121820 181825:0e1319 11111b:121820 \
    89b4fa:88a4ad b4befe:c8c4bb 9399b2:6a7175 cba6f7:88a4ad f38ba8:b37a72 eba0ac:b37a72 \
    f9e2af:c4b48a a6e3a1:8ca483 6c7086:4a5a63 7f849c:5f6e76 fab387:b8977a 94e2d5:7fa3a3 \
    74c7ec:7a98ab 89dceb:7fa3a3 f5c2e7:9c8898 f2cdcd:c8b9a4 cdd6f4:c8c4bb bac2de:b3b0a8 \
    a6adc8:9db4ad f5e0dc:d8d4cc

for var in (set -U --names | string match 'tide_*color*')
    set -l value (string lower -- $$var)
    for pair in $tsukiyo_map
        set -l kv (string split : -- $pair)
        if test "$value" = "$kv[1]"
            set -U $var $kv[2]
            break
        end
    end
end
