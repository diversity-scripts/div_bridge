local Adapter = {}

---@param source number
---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(source, data)
    local _type = data.type
    if _type == 'warning' then
        _type = 'error'
    end

    TriggerClientEvent('17mov_Hud:ShowNotification', source, dBridge.sanitize(data.text or data.message or ''), _type, '', data.duration or 5000)
end

return Adapter
