Bridge.loadOxLib()
local Notification = {}

---@return string
Notification.GetResourceName = function()
    return 'ox_lib'
end

---@param source number
---@param message string
---@param _type? 'success' | 'error' | 'info' | 'warning'
---@param duration? number
Notification.Notify = function(source, message, _type, duration)
    lib.notify(source, {
        id = 'div_bridge_notify',
        description = message,
        type = _type or 'info',
        duration = duration or 5000
    })
end

return Notification
