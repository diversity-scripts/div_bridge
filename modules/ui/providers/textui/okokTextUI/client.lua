local okokTextUI = exports['okokTextUI']
local Adapter = {}

---@param text string
Adapter.ShowTextUI = function(text)
    okokTextUI:Open(dBridge.sanitize(text), 'lightgrey', 'right', false)
end

Adapter.HideTextUI = function()
    okokTextUI:Close()
end

return Adapter
