local Config = require("config")

require("events.tab-title").setup()
require("events.right-status").setup()
require("events.startup").setup()

return Config:init()
	:append(require("config.domains"))
	:append(require("config.font"))
	:append(require("config.keymaps"))
	:append(require("config.appearance")).options
