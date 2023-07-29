local M = {}

local config = require("dap-info.config")
local breakpoint_util = require("dap-info.breakpoint-utils")

_DAP_INFO_VIRT_TEXT_MAP = {}

local BREAK_POINT_TYPES = {
  REGULAR = 0,
  LOG_POINT = 1,
  CONDITIONAL = 2,
}
local VIRTUAL_TEXT_HIGHLIGHT_MAP = {
  [BREAK_POINT_TYPES.CONDITIONAL] = "DapBreakpointCondition",
  [BREAK_POINT_TYPES.LOG_POINT] = "DapLogPoint",
  [BREAK_POINT_TYPES.REGULAR] = "DapBreakpoint",
}

function M.is_special_breakpoint(target)
  if target.logMessage ~= nil or target.condition ~= nil then
    return true
  else
    return false
  end
end

function M.get_breakpoint_type(target)
  if target.logMessage ~= nil then
    return BREAK_POINT_TYPES.LOG_POINT
  elseif target.condition ~= nil then
    return BREAK_POINT_TYPES.CONDITIONAL
  else
    return BREAK_POINT_TYPES.REGULAR
  end
end

function M.clear_virt_text_on_line(_line, _bufnr)
  local bufnr = _bufnr or vim.fn.bufnr()
  local line = _line or vim.fn.line(".")

  local virt_text_ns = vim.api.nvim_create_namespace(config.virt_text_opts.namespace)
  local extmarks = vim.api.nvim_buf_get_extmarks(
    bufnr,
    virt_text_ns,
    { line - 1, 0 },
    { line - 1, -1 },
    { details = true }
  )

  for _, extmark in ipairs(extmarks) do
    local mark_line = extmark[2]
    vim.api.nvim_buf_clear_namespace(bufnr, virt_text_ns, mark_line, mark_line + 1)
    _DAP_INFO_VIRT_TEXT_MAP[bufnr][line] = nil
  end
end

function M.clear_virt_text_in_buffer(_bufnr)
  local bufnr = _bufnr or vim.fn.bufnr()
  local saved_virt_text_lines = _DAP_INFO_VIRT_TEXT_MAP[bufnr]
  if saved_virt_text_lines ~= nil then
    for line, _ in pairs(saved_virt_text_lines) do
      M.clear_virt_text_on_line(line)
    end
  end
end

function M.create_virt_text_chunks_by_breakpoints(breakpoints)
  local special_breakpoints = {}
  for _, breakpoint in ipairs(breakpoints) do
    if M.is_special_breakpoint(breakpoint) then
      special_breakpoints[#special_breakpoints + 1] = breakpoint
    end
  end

  if #special_breakpoints == 0 then
    return nil
  end

  local prefix = config.virt_text_opts.prefix
  local suffix = config.virt_text_opts.suffix
  local spacing = config.virt_text_opts.spacing

  -- Create a little more space between virtual text and contents
  local virt_texts = { { string.rep(" ", spacing) } }

  for i = 1, #special_breakpoints do
    local resolved_prefix = prefix
    if type(prefix) == "function" then
      resolved_prefix = prefix(special_breakpoints[i]) or ""
    end
    table.insert(
      virt_texts,
      { resolved_prefix, VIRTUAL_TEXT_HIGHLIGHT_MAP[M.get_breakpoint_type(special_breakpoints[i])] }
    )
  end

  local last_special_breakpoint = special_breakpoints[#special_breakpoints]
  local message = ""
  local last_breakpoint_type = M.get_breakpoint_type(last_special_breakpoint)
  if last_breakpoint_type == BREAK_POINT_TYPES.CONDITIONAL then
    message = last_special_breakpoint.condition
  elseif last_breakpoint_type == BREAK_POINT_TYPES.LOG_POINT then
    message = last_special_breakpoint.logMessage
  end

  if type(suffix) == "function" then
    suffix = suffix(last_special_breakpoint) or ""
  end

  table.insert(virt_texts, {
    string.format(" %s%s", message:gsub("\r", ""):gsub("\n", "  "), suffix),
    VIRTUAL_TEXT_HIGHLIGHT_MAP[last_breakpoint_type],
  })

  return virt_texts
end

function M.show_line_breakpoint_info_in_virt_text(_line, _bufnr)
  local bufnr = _bufnr or vim.fn.bufnr()
  local line = _line or vim.fn.line(".")

  local virt_text_ns = vim.api.nvim_create_namespace(config.virt_text_opts.namespace)
  local breakpoints = breakpoint_util.get_breakpoints_on_line(line, bufnr)
  local virt_text = M.create_virt_text_chunks_by_breakpoints(breakpoints)

  local cached_buffer_info = _DAP_INFO_VIRT_TEXT_MAP[bufnr] or {}
  if vim.fn.bufloaded(bufnr) ~= 0 then
    local success, id = pcall(vim.api.nvim_buf_set_extmark, bufnr, virt_text_ns, line - 1, 0, {
      hl_mode = "combine",
      id = cached_buffer_info[line],
      virt_text = virt_text,
    })
    if success then
      _DAP_INFO_VIRT_TEXT_MAP[bufnr] = vim.tbl_deep_extend("force", cached_buffer_info, { [line] = id })
    end
  end
end

function M.show_buffer_breakpoint_info_in_virt_text(_bufnr)
  local bufnr = _bufnr or vim.fn.bufnr()

  local breakpoints = breakpoint_util.get_breakpoints_in_buffer(bufnr)
  if breakpoints == nil then
    return
  end

  for _, breakpoint in ipairs(breakpoints) do
    M.show_line_breakpoint_info_in_virt_text(breakpoint.line, bufnr)
  end
end

function M.reload_buffer_virt_text(_bufnr)
  local bufnr = _bufnr or vim.fn.bufnr()

  M.clear_virt_text_in_buffer(bufnr)
  M.show_buffer_breakpoint_info_in_virt_text(bufnr)
end

return M
