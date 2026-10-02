local Adapter = {}

---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(data)
    local title = data.title and dBridge.sanitize(data.title) or ''
    local message = dBridge.sanitize(data.text or data.message or '')
    exports['okokNotify']:Alert(title, message, data.duration or 5000, data.type or 'info')
end

return Adapter
