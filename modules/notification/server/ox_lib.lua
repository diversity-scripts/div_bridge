Bridge.loadLib()

return {
    ---@param source number
    ---@param message string
    ---@param _type? 'success' | 'error' | 'info' | 'warning'
    ---@param duration? number
    Notify = function(source, message, _type, duration)
        lib.notify(source, {
            description = message,
            type = _type or 'info',
            duration = duration or 5000
        })
    end,
}