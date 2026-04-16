local TextUI = {}

local function getFramework()
    local framework = Bridge.Framework
    if type(framework) ~= 'table' then
        error('TextUI: Bridge.Framework failed to load or is invalid. Please check your config.')
    end
    return framework
end

local framework = getFramework()

---@return string
TextUI.GetResourceName = function()
    return 'framework'
end

---@param text string
TextUI.Show = function(text)
    assert(framework.ShowTextUI, 'Your framework does not provide a client-side "ShowTextUI" function. Please review your bridge config.')
    framework:ShowTextUI(text)
end

TextUI.Hide = function()
    assert(framework.HideTextUI, 'Your framework does not provide a client-side "HideTextUI" function. Please review your bridge config.')
    framework:HideTextUI()
end

return TextUI
