-------------------------------------------------------------------------------
-- Custom UI Adapter (Server)
-- Template for server owners to implement their own server-side UI provider.
-------------------------------------------------------------------------------

local Adapter = {}

---@param source number Player server ID
---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(source, data)
    -- Your custom server-side notification implementation here
end

return Adapter
