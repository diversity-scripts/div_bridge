local brutal_textui = exports['brutal_textui']
local TextUI = {}

---@return string
TextUI.GetResourceName = function()
    return 'brutal_textui'
end

---@param text string
TextUI.Show = function(text)
    brutal_textui:Open(text, 'gray', 1, 'right')
end

TextUI.Hide = function()
    brutal_textui:Close()
end

return TextUI