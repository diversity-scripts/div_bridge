local Notification = {}

---@return string
Notification.GetResourceName = function()
    return 'custom'
end

---@param message string
---@param _type? 'success' | 'error' | 'info' | 'warning'
---@param duration? number
Notification.Notify = function(message, _type, duration)

end

return Notification
