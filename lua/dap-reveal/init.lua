local M = {}

local util = require("dap-reveal.breakpoint-utils")
local config = require("dap-reveal.config")

local setup_commands = function()
  vim.api.nvim_create_user_command("DapInfoNextBp", function()
    util.go_to_next_breakpoint()
  end, {})
  vim.api.nvim_create_user_command("DapInfoPrevBp", function()
    util.go_to_next_breakpoint(true)
  end, {})
  vim.api.nvim_create_user_command("DapInfoRevealBp", function()
    util.show_breakpoint_info_on_current_line()
  end, {})
  vim.api.nvim_create_user_command("DapInfoUpdateBp", function()
    util.update_breakpoint_on_current_line()
  end, {})
end

M.setup = function(_config)
  local final_cfg = vim.tbl_extend("force", config, _config or {})
  for key, val in pairs(final_cfg) do
    config[key] = val
  end

  setup_commands()
end

return M
