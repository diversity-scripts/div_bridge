return {
    ---@param source number
    ---@param message string
    ---@param _type? 'success' | 'error' | 'inform' | 'warning'
    ---@param duration? number
    Notify = function(source, message, _type, duration)
        if _type == 'warning' then
            _type = 'error'
        end

        TriggerClientEvent("17mov_Hud:ShowNotification", source, message, _type, '', duration or 5000)
    end,
}