local Notification = {}

local function getFramework()
    local framework = Bridge.Framework
    if type(framework) ~= 'table' then
        error('Bridge.Framework failed to load or is invalid. Please check your config.')
    end
    return framework
end

---@return string
Notification.GetResourceName = function()
    return 'framework'
end

---@param message string
---@param _type? 'success' | 'error' | 'info' | 'warning'
---@param duration? number
Notification.Notify = function(message, _type, duration)
    local framework = getFramework()
    assert(framework.Notify, 'Your framework does not provide a "Notify" function. Please review your bridge config.')
    framework.Notify(message, _type, duration)
end

return Notification
