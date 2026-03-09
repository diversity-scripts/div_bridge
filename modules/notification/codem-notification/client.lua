local Notification = {}

---@return string
Notification.GetResourceName = function()
    return 'codem-notification'
end

---@param message string
---@param _type? 'success' | 'error' | 'inform' | 'warning'
---@param duration? number
Notification.Notify = function(message, _type, duration)
    if _type == 'warning' then
        _type = 'error'
    end

    TriggerEvent('codem-notification:Create', message, _type, nil, duration or 4000)
end

return Notification
