local Notification = {}

---@return string
Notification.GetResourceName = function()
    return 'custom'
end

---@param source number
---@param message string
---@param _type? 'success' | 'error' | 'info' | 'warning'
---@param duration? number
Notify = function(source, message, _type, duration)

end

return Notification
