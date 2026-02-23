return {
    ---@param message string
    ---@param _type? 'success' | 'error' | 'info' | 'warning'
    ---@param duration? number
    Notify = function(message, _type, duration)
        exports.pNotify:SendNotification({
            text = message,
            type = _type or 'info',
            timeout = duration or 5000
        })
    end,
}