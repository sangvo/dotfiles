local g = vim.g
local cmd = vim.cmd

g.go_fmt_command = "goimports"
g.go_fmt_autosave = 0 --"use nvim formatter
g.go_list_type = "quickfix"
g.go_fmt_fail_silently = 1

g.go_highlight_functions = 1
g.go_highlight_methods = 1
g.go_highlight_structs = 1
g.go_highlight_interfaces = 1
g.go_highlight_operators = 1
g.go_highlight_build_constraints = 1
g.go_jump_to_error = 1

g.go_gocode_propose_source = 0 --" changed 1 -> 0 (so get fast)
g.go_gocode_unimported_packages = 1
g.go_gocode_propose_builtins = 1
g.go_gocode_socket_type = "unix"
