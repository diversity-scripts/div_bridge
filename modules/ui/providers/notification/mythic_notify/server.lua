local Adapter = {}

---@param source number
---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(source, data)
    local _type = data.type
    if _type == 'info' then
        _type = 'inform'
    elseif _type == 'warning' then
        _type = 'error'
    end

    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = _type or 'inform', text = dBridge.sanitize(data.text or data.message or ''), length = data.duration or 5000 })
end

return Adapter
