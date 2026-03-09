Bridge.loadOxLib()
local TextUI = {}

---@return string
TextUI.GetResourceName = function()
    return 'ox_lib'
end

---@param text string
TextUI.Show = function(text)
    lib.showTextUI(text)
end

TextUI.Hide = function()
    lib.hideTextUI()
end

return TextUI