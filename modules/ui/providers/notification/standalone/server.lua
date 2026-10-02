local Adapter = {}

---@param source number
---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(source, data)
    local message = dBridge.sanitize(data.text or data.message or '')
    local _type = data.type

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

return Adapter
