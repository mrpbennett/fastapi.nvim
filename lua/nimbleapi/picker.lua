local M = {}

local _detected_backend = nil

--- Detect which picker backend to use (result is memoized).
---@return "telescope"|"snacks"|"builtin"
local function detect_provider()
  if _detected_backend then
    return _detected_backend
  end
  if pcall(require, "snacks.picker") then
    _detected_backend = "snacks"
  elseif pcall(require, "telescope") then
    _detected_backend = "telescope"
  else
    _detected_backend = "builtin"
  end
  return _detected_backend
end

--- Open a picker for routes.
--- The backend is determined by `config.options.picker.provider` (explicit) or
--- auto-detected in order: snacks → telescope → builtin.
---@param opts? table  Passed through to the backend picker
function M.picker(opts)
  local config = require("nimbleapi.config")
  local provider = (config.options.picker or {}).provider or detect_provider()

  local ok, backend = pcall(require, "nimbleapi.pickers." .. provider)
  if not ok then
    vim.notify(
      "nimbleapi.nvim: could not load picker backend '" .. provider .. "': " .. backend,
      vim.log.levels.ERROR
    )
    return
  end

  backend.picker(opts)
end

M.pick = M.picker -- backward compat (telescope extension)

return M
