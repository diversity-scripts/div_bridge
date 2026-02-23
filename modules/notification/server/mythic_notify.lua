return {
    ---@param source number
    ---@param message string
    ---@param _type? 'success' | 'error' | 'inform' | 'warning'
    ---@param duration? number
    Notify = function(source, message, _type, duration)
        if _type == 'info' then
            _type = 'inform'
        elseif _type == 'warning' then
            _type = 'error'
        end

        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = _type or 'inform', text = message, length = duration or 5000 })
    end,
}