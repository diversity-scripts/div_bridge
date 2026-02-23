return {
    ---@param message string
    ---@param _type? 'success' | 'error' | 'info' | 'warning'
    ---@param duration? number
    Notify = function(message, _type, duration)
        exports['okokNotify']:Alert('', message, duration or 5000, _type or 'info')
    end,
}