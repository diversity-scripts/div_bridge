local Adapter = {}

---@param source number
---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(source, data)
    local title = data.title and dBridge.sanitize(data.title) or ''
    local message = dBridge.sanitize(data.text or data.message or '')
    TriggerClientEvent('okokNotify:Alert', source, title, message, data.duration or 5000, data.type or 'info')
end

return Adapter
