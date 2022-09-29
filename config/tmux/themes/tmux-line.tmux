set -g status 'on'
# statusbar black background
set -g status-bg default

set -g status-position bottom
set -g status-justify 'centre'
set -g status-left-length '0'
set -g status-right-length '0'

# set-option -g window-status-current-format  '\
#[fg=colour15,bg=colour161] #W \
#[bg=#1b2b34]'

# set-option -g window-status-format '#[fg=colour15,bg=colour24] #W '

# set -g status-left '\
#[fg=colour232,bg=#6272a4] SANG-VO \
#[bg=#1b2b34] \
#[fg=colour232,bg=#6272a4] UPTIME: #(uptime | cut -f 4-5 -d " " | cut -f 1 -d ",") '

# set -g status-right '\
#[fg=colour232,bg=#6272a4] CPU: #{cpu_icon} #{cpu_percentage} \
#[bg=#1b2b34] \
#[fg=colour232,bg=#6272a4] MEM: #{ram_icon} #{ram_percentage} \
##[bg=#1b2b34] \
#[fg=colour232,bg=#6272a4] %a %Y-%m-%d'
