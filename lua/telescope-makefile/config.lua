local config = {}

config.defaults = {
  -- The path where to search the makefile in the priority order
  makefile_priority = { ".", "build/" },
  toggle_term = {
    cmd = 'make',
    direction = 'float',
    close_on_exit = false,
  },
}

setmetatable(config, { __index = config.defaults })

return config
