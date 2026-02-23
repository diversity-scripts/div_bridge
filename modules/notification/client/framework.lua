return {
    ---@param message string
    ---@param _type? 'success' | 'error' | 'info' | 'warning'
    ---@param duration? number
    Notify = function(message, _type, duration)
        Bridge.Framework.Notify(message, _type, duration)
    end,
}