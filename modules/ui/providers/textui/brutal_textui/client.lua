local brutal_textui = exports['brutal_textui']
local Adapter = {}

---@param text string
Adapter.ShowTextUI = function(text)
    brutal_textui:Open(dBridge.sanitize(text), 'gray', 1, 'right')
end

Adapter.HideTextUI = function()
    brutal_textui:Close()
end

return Adapter
