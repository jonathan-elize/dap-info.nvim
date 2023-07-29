local M = {}

local breakpoint_info_utils = require("dap-reveal.breakpoint-info-utils")
local virt_text_util = require("dap-reveal.virt-text-utils")
local config = require("dap-reveal.config")

local setup_commands = function()
  vim.api.nvim_create_user_command("DapInfoNextBp", function()
    breakpoint_info_utils.go_to_next_breakpoint()
  end, {})
  vim.api.nvim_create_user_command("DapInfoPrevBp", function()
    breakpoint_info_utils.go_to_next_breakpoint(true)
  end, {})
  vim.api.nvim_create_user_command("DapInfoRevealBp", function()
    breakpoint_info_utils.show_breakpoint_info_on_current_line()
  end, {})
  vim.api.nvim_create_user_command("DapInfoUpdateBp", function()
    breakpoint_info_utils.update_breakpoint_on_current_line()
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
