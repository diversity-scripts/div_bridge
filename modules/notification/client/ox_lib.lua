Bridge.loadLib()

return {
    ---@param message string
    ---@param _type? 'success' | 'error' | 'info' | 'warning'
    ---@param duration? number
    Notify = function(message, _type, duration)
        lib.notify({
            description = message,
            type = _type or 'info',
            duration = duration or 5000
        })
    end,
}