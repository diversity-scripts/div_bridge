local TextUI = {}

---@return string
TextUI.GetResourceName = function()
    return 'cd_drawtextui'
end

---@param text string
TextUI.Show = function(text)
    TriggerEvent('cd_drawtextui:ShowUI', 'show', text)
end

TextUI.Hide = function()
    TriggerEvent('cd_drawtextui:HideUI')
end

return TextUI