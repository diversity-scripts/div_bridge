return {
    ---@param message string
    ---@param _type? 'success' | 'error' | 'inform' | 'warning'
    ---@param duration? number
    Notify = function(message, _type, duration)
        if _type == 'warning' then
            _type = 'error'
        end

        exports['17mov_Hud']:ShowNotification(message, _type, '', duration or 5000)
    end,
}