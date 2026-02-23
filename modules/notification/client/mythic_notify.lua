return {
    ---@param message string
    ---@param _type? 'success' | 'error' | 'info' | 'warning'
    ---@param duration? number
    Notify = function(message, _type, duration)
        if _type == 'info' then
            _type = 'inform'
        elseif _type == 'warning' then
            _type = 'error'
        end

        exports['mythic_notify']:DoCustomHudText(_type or 'info', message, duration or 5000)
    end,
}