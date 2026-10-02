local codem_textui = exports['codem-textui']
local Adapter = {}

---@param text string
Adapter.ShowTextUI = function(text)
    codem_textui:OpenTextUI(dBridge.sanitize(text), 'thema-1')
end

Adapter.HideTextUI = function()
    codem_textui:CloseTextUI()
end

return Adapter
