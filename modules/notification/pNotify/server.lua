local Notification = {}

---@return string
Notification.GetResourceName = function()
    return 'pNotify'
end

---@param source number
---@param message string
---@param _type? 'success' | 'error' | 'info' | 'warning'
---@param duration? number
Notification.Notify = function(source, message, _type, duration)
    TriggerClientEvent('pNotify:SendNotification', source, {
        text = message,
        type = _type or 'info',
        timeout = duration or 5000
    })
end

return Notification
