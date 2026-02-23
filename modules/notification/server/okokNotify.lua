return {
    ---@param source number
    ---@param message string
    ---@param _type? 'success' | 'error' | 'info' | 'warning'
    ---@param duration? number
    Notify = function(source, message, _type, duration)
        TriggerClientEvent('okokNotify:Alert', source, '', message, duration or 5000, _type or 'info')
    end,
}