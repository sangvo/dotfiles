set-option -g status-fg colour7
set-option -g status-bg default
set-option -g status-justify left
set-option -g status-left-length 15
set-option -g status-left '#[fg=colour15](#[fg=colour6]C-a#[fg=colour15]) #[fg=colour11][#[fg=colour13]#H##[fg=colour11]] [default]'
set-option -g status-right-length 20
set-option -g status-right '#[fg=colour11][#[fg=colour13]#(date +"%m/%d %H:%M")#[fg=colour11]]#[fg=default]'
set-window-option -g window-status-current-format '#[fg=colour10,bg=default]#I:#W#[fg=default]'
