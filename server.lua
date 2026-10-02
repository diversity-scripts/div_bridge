-------------------------------------------------------------------------------
-- div_bridge Server Entry Point
-- Runs inside div_bridge's own script context. External resources load init.lua
-- via LoadResourceFile/load(); when they do, init.lua detects it's running
-- outside div_bridge and sets Bridge.UI to a proxy that calls
-- exports['div_bridge'] — which executes here, in the right context.
--
-- Only notification-style UI methods are meaningful on the server (dialogs,
-- context menus, minigames, text UI, etc. are client-only). The server module
-- (modules/ui/server.lua) implements the notify family; these exports simply
-- forward to it so the proxy round-trip works the same way it does on the client.
--
-- NOTE: unlike client exports, these forward the caller's args as-is. The server
-- UI methods take an explicit target/player id, so no 'source' is assumed.
-------------------------------------------------------------------------------

local bridgeInit = LoadResourceFile('div_bridge', 'init.lua')
if bridgeInit then
    load(bridgeInit, '@@div_bridge/init.lua')()
end

-- init.lua keeps Bridge local and only exposes it as dBridge in the environment,
-- so grab a local reference here for the export wrappers below.
local Bridge = _ENV.dBridge

-------------------------------------------------------------------------------
-- UI exports — called by the proxy in external resources
-------------------------------------------------------------------------------

-- Provider introspection
exports('GetProvider',       function(component)   return Bridge.UI.GetProvider(component) end)

-- Notifications (server -> client)
exports('Notify',            function(target, d)   return Bridge.UI.Notify(target, d) end)
exports('ToPlayer',          function(target, d)   return Bridge.UI.ToPlayer(target, d) end)
exports('ToAllPlayers',      function(d)           return Bridge.UI.ToAllPlayers(d) end)
exports('ToJob',             function(job, d)      return Bridge.UI.ToJob(job, d) end)
exports('ToACEPermission',   function(perm, d)     return Bridge.UI.ToACEPermission(perm, d) end)
