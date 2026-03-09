local jg_textui = exports['jg-textui']
local TextUI = {}

---@return string
TextUI.GetResourceName = function()
    return 'jg-textui'
end

---@param text string
TextUI.Show = function(text)
    jg_textui:DrawText(text)
end

TextUI.Hide = function()
    jg_textui:HideText()
end

return TextUI