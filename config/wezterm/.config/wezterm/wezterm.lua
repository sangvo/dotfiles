local Config = require 'config'

require('events.tab-title').setup()
require('events.right-status').setup()

return Config:init()
  :append(require('config.font'))
  :append(require('config.keymaps'))
  :append(require('config.appearance')).options
