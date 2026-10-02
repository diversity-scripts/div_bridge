local Adapter = {}

---@param source number
---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(source, data)
    local _type = data.type
    if _type == 'warning' then
        _type = 'error'
    end

    TriggerClientEvent('codem-notification:Create', source, dBridge.sanitize(data.text or data.message or ''), _type, nil, data.duration or 4000)
end

return Adapter
