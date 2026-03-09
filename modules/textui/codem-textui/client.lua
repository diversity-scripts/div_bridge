local codem_textui = exports['codem-textui']
local TextUI = {}

---@return string
TextUI.GetResourceName = function()
    return 'codem-textui'
end

---@param text string
TextUI.Show = function(text)
    codem_textui:OpenTextUI(text, 'thema-1')
end

TextUI.Hide = function()
    codem_textui:CloseTextUI()
end

return TextUI