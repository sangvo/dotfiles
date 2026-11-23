local wezterm = require("wezterm")

-- One SSH domain per concrete Host in ~/.ssh/config (Includes resolved), named "SSH:<host>".
-- The servers don't run wezterm, so there is no multiplexing; Posix shell keeps splits in the cwd.
local domains = {}
for host, opts in pairs(wezterm.enumerate_ssh_hosts()) do
	if not host:find("[*?!]") and not host:match("^github%.com") then
		local ssh_option = {}
		-- wezterm's ssh client ignores ProxyJump (supported only after 20240203), so hop with OpenSSH
		if opts.proxyjump and not opts.proxycommand then
			ssh_option.proxycommand =
				string.format("ssh -W %s:%s %s", opts.hostname or host, opts.port or "22", opts.proxyjump)
		end
		table.insert(domains, {
			name = "SSH:" .. host,
			remote_address = host,
			multiplexing = "None",
			assume_shell = "Posix",
			ssh_option = ssh_option,
		})
	end
end
table.sort(domains, function(a, b)
	return a.name < b.name
end)

return {
	ssh_domains = domains,
}
