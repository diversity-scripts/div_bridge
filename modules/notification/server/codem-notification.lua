return {
    ---@param source number
    ---@param message string
    ---@param _type? 'success' | 'error' | 'inform' | 'warning'
    ---@param duration? number
    Notify = function(source, message, _type, duration)
        if _type == 'warning' then
            _type = 'error'
        end

        TriggerClientEvent('codem-notification:Create', source, message, _type, nil, duration or 4000)
    end,
}