local Notification = {}

---@return string
Notification.GetResourceName = function()
    return 'standalone'
end

---@param message string
---@param _type? 'success' | 'error' | 'inform'
---@param duration? number
Notification.Notify = function(message, _type, duration)
    if _type == 'error' then
        message = '~r~' .. message
    elseif _type == 'warning' then
        message = '~y~' .. message
    elseif _type == 'success' then
        message = '~g~' .. message
    elseif _type == 'info' then
        message = '~b~' .. message
    end

    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(true, false)
end

return Notification
