return {
    ---@param message string
    ---@param _type? 'success' | 'error' | 'inform'
    ---@param duration? number
    Notify = function(message, _type, duration)
        if _type == 'error' then
            message = '~r~' .. message
        elseif _type == 'warning' then
            message = '~y~' .. message
        elseif _type == 'success' then
            message = '~g~' .. message
        elseif _type == 'info' then
            message = '~b~' .. message
        end

        SetTextComponentFormat('STRING')
        AddTextComponentString(message)
        EndTextCommandDisplayHelp(0, 0, 0, -1)
    end,
}