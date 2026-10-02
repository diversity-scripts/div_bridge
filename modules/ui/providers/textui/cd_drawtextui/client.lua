local Adapter = {}

---@param text string
Adapter.ShowTextUI = function(text)
    TriggerEvent('cd_drawtextui:ShowUI', 'show', dBridge.sanitize(text))
end

Adapter.HideTextUI = function()
    TriggerEvent('cd_drawtextui:HideUI')
end

return Adapter
