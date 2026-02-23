return {
    ---@param source number
    ---@param message string
    ---@param _type? 'success' | 'error' | 'info' | 'warning'
    ---@param duration? number
    Notify = function(source, message, _type, duration)
        TriggerClientEvent('pNotify:SendNotification', source, {
            text = message,
            type = _type or 'info',
            timeout = duration or 5000
        })
    end,
}