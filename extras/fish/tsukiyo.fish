# Tsukiyo for fish: parchment commands, quiet punctuation, mist for what matters.
# install-extras.sh copies this to ~/.config/fish/conf.d/, so it loads in every session.
# Global (not universal) variables: removing the file restores your previous colors.

status is-interactive; or exit

set -g fish_color_normal c8c4bb
set -g fish_color_command 88a4ad
set -g fish_color_keyword 9c8898
set -g fish_color_quote 8ca483
set -g fish_color_redirection 7fa3a3
set -g fish_color_end 6a7175
set -g fish_color_error b37a72
set -g fish_color_param c8c4bb
set -g fish_color_valid_path --underline
set -g fish_color_option b3b0a8
set -g fish_color_comment 5f6e76 --italics
set -g fish_color_operator 7fa3a3
set -g fish_color_escape 7fa3a3
set -g fish_color_autosuggestion 4a5a63
set -g fish_color_selection --background=243039
set -g fish_color_search_match --background=2b3a44
set -g fish_color_history_current --bold
set -g fish_color_cancel b37a72 --reverse
set -g fish_color_cwd 88a4ad
set -g fish_color_cwd_root b37a72
set -g fish_color_user 9db4ad
set -g fish_color_host 88a4ad
set -g fish_color_host_remote c4b48a
set -g fish_color_status b37a72

set -g fish_pager_color_progress 6a7175
set -g fish_pager_color_prefix 88a4ad --bold
set -g fish_pager_color_completion c8c4bb
set -g fish_pager_color_description 6a7175 --italics
set -g fish_pager_color_selected_background --background=243039
set -g fish_pager_color_selected_prefix 88a4ad --bold
set -g fish_pager_color_selected_completion d8d4cc
set -g fish_pager_color_selected_description 9db4ad
