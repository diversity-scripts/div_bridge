local jg_textui = exports['jg-textui']
local Adapter = {}

---@param text string
Adapter.ShowTextUI = function(text)
    jg_textui:DrawText(dBridge.sanitize(text))
end

Adapter.HideTextUI = function()
    jg_textui:HideText()
end

return Adapter
