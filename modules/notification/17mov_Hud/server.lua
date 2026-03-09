local Notification = {}

---@return string
Notification.GetResourceName = function()
    return '17mov_Hud'
end

---@param source number
---@param message string
---@param _type? 'success' | 'error' | 'inform' | 'warning'
---@param duration? number
Notification.Notify = function(source, message, _type, duration)
    if _type == 'warning' then
        _type = 'error'
    end

    TriggerClientEvent('17mov_Hud:ShowNotification', source, message, _type, '', duration or 5000)
end

return Notification
