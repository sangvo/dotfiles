set -g status 'on'
set -g status-position bottom
set -g status-justify 'centre'
set -g status-left-length '100'
set -g status-right-length '100'

set -g status-bg default

set-option -g window-status-current-format  '\
#[fg=colour15,bg=colour161] #W \
#[bg=#1b2b34]'

set-option -g window-status-format '#[fg=colour15,bg=colour24] #W '

set -g status-left '\
#[fg=colour232,bg=#6272a4] SANG-VO \
#[bg=#1b2b34] \
#[fg=colour232,bg=#6272a4] UPTIME: #(uptime | cut -f 4-5 -d " " | cut -f 1 -d ",") '
#[fg=colour232,bg=colour154] #(rainbarf --battery --remaining --no-rgb) '

set -g status-right '\
#{?client_prefix,🐺,} \
#[fg=colour232,bg=#6272a4] CPU:#{cpu_percentage} \
#[bg=#1b2b34] \
#[fg=colour232,bg=#6272a4] MEM:#{ram_percentage} '
