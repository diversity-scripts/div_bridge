local Adapter = {}

---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(data)
    local _type = data.type
    if _type == 'warning' then
        _type = 'error'
    end

    exports['17mov_Hud']:ShowNotification(dBridge.sanitize(data.text or data.message or ''), _type, '', data.duration or 5000)
end

return Adapter
