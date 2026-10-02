local Adapter = {}

---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(data)
    exports.pNotify:SendNotification({
        text = dBridge.sanitize(data.text or data.message or ''),
        type = data.type or 'info',
        timeout = data.duration or 5000
    })
end

return Adapter
