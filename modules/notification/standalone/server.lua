local Notification = {}

---@return string
Notification.GetResourceName = function()
    return 'standalone'
end

---@param source number
---@param message string
---@param _type? 'success' | 'error' | 'info' | 'warning'
---@param duration? number
Notification.Notify = function(source, message, _type, duration)
    if _type == 'error' then
        message = '~r~' .. message
    elseif _type == 'warning' then
        message = '~y~' .. message
    elseif _type == 'success' then
        message = '~g~' .. message
    elseif _type == 'info' then
        message = '~b~' .. message
    end

    print(('^4[div_bridge] Standalone Notification: %s^0'):format(message))
end

return Notification
