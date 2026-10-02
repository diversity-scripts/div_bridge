local Adapter = {}

---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(data)
    local _type = data.type
    if _type == 'info' then
        _type = 'inform'
    elseif _type == 'warning' then
        _type = 'error'
    end

    exports['mythic_notify']:DoCustomHudText(_type or 'inform', dBridge.sanitize(data.text or data.message or ''), data.duration or 5000)
end

return Adapter
