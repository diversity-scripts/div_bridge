-------------------------------------------------------------------------------
-- ox_lib UI Adapter (Server)
-- Handles server-side notifications via ox_lib.
-------------------------------------------------------------------------------

dBridge.loadOxLib()

local Adapter = {}

---@param source number
---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(source, data)
    lib.notify(source, {
        title = data.title and dBridge.sanitize(data.title) or nil,
        description = dBridge.sanitize(data.text or data.message or ''),
        type = data.type or 'info',
        duration = data.duration or 5000
    })
end

return Adapter
