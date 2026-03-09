local okokTextUI = exports['okokTextUI']
local TextUI = {}

---@return string
TextUI.GetResourceName = function()
    return 'okokTextUI'
end

---@param text string
TextUI.Show = function(text)
    okokTextUI:Open(text, 'lightgrey', 'right', false)
end

TextUI.Hide = function()
    okokTextUI:Close()
end

return TextUI