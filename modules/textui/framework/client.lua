local TextUI = {}

local function getFramework()
    local framework = Bridge.Framework
    if type(framework) ~= 'table' then
        error('Bridge.Framework failed to load or is invalid. Please check your config.')
    end
    return framework
end

---@return string
TextUI.GetResourceName = function()
    return 'framework'
end

---@param text string
TextUI.Show = function(text)
    local framework = getFramework()
    assert(framework.ShowTextUI, 'Your framework does not provide a "ShowTextUI" function. Please review your bridge config.')
    framework:ShowTextUI(text)
end

TextUI.Hide = function()
    local framework = getFramework()
    assert(framework.HideTextUI, 'Your framework does not provide a "HideTextUI" function. Please review your bridge config.')
    framework:HideTextUI()
end

return TextUI
