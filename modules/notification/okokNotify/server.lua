local Notification = {}

---@return string
Notification.GetResourceName = function()
    return 'okokNotify'
end

---@param source number
---@param message string
---@param _type? 'success' | 'error' | 'info' | 'warning'
---@param duration? number
Notification.Notify = function(source, message, _type, duration)
    TriggerClientEvent('okokNotify:Alert', source, '', message, duration or 5000, _type or 'info')
end

return Notification
