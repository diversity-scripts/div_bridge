-------------------------------------------------------------------------------
-- Framework UI Adapter (Server)
-- Uses the loaded framework's built-in server-side Notify function.
-------------------------------------------------------------------------------

local Adapter = {}

local framework = dBridge.getFramework('UI Framework Adapter')

---@param source number
---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(source, data)
    assert(framework.Notify, 'Your framework does not provide a server-side "Notify" function.')
    framework.Notify(source, dBridge.sanitize(data.text or data.message or ''), data.type, data.duration)
end

return Adapter
