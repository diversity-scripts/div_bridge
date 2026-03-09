local Notification = {}

---@return string
Notification.GetResourceName = function()
    return 'mythic_notify'
end

---@param message string
---@param _type? 'success' | 'error' | 'inform' | 'warning'
---@param duration? number
Notification.Notify = function(message, _type, duration)
    if _type == 'info' then
        _type = 'inform'
    elseif _type == 'warning' then
        _type = 'error'
    end

    exports['mythic_notify']:DoCustomHudText(_type or 'info', message, duration or 5000)
end

return Notification
