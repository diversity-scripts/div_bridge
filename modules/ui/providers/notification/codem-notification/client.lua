local Adapter = {}

---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(data)
    local _type = data.type
    if _type == 'warning' then
        _type = 'error'
    end

    TriggerEvent('codem-notification:Create', dBridge.sanitize(data.text or data.message or ''), _type, nil, data.duration or 4000)
end

return Adapter
