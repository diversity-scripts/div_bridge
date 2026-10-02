-------------------------------------------------------------------------------
-- div_bridge Client Entry Point
-- Runs inside div_bridge's own script context so SendNUIMessage correctly
-- targets div_bridge's NUI page.
--
-- External resources load init.lua via LoadResourceFile/load(). When they do,
-- init.lua detects it's running outside div_bridge and sets Bridge.UI to a
-- proxy that calls exports['div_bridge'] — which executes here, in the right
-- context. Same pattern as ox_lib.
--
-- NOTE: Client-side exports do NOT inject a source argument (unlike server).
-- Handlers receive exactly the args passed by the caller, no extras.
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
exports('GetProvider',          function(component)  return Bridge.UI.GetProvider(component) end)

-- Notification
exports('Notify',               function(d)          return Bridge.UI.Notify(d) end)
exports('NotifyUpdate',         function(id, d)      return Bridge.UI.NotifyUpdate(id, d) end)
exports('NotifyClose',          function(id)         return Bridge.UI.NotifyClose(id) end)

-- Context Menu
exports('RegisterContext',      function(d)
    if type(d) == 'table' then
        d._sourceResource = GetInvokingResource()
    end
    return Bridge.UI.RegisterContext(d)
end)
exports('ShowContext',          function(id)         return Bridge.UI.ShowContext(id) end)
exports('HideContext',          function()           return Bridge.UI.HideContext() end)
exports('UpdateContext',        function(id, d)      return Bridge.UI.UpdateContext(id, d) end)
exports('GetOpenContextMenu',   function()           return Bridge.UI.GetOpenContextMenu() end)

-- TextUI
exports('ShowTextUI',           function(id, d)      return Bridge.UI.ShowTextUI(id, d) end)
exports('HideTextUI',           function(id)         return Bridge.UI.HideTextUI(id) end)
exports('UpdateTextUI',         function(id, d)      return Bridge.UI.UpdateTextUI(id, d) end)

-- Progress
exports('Progress',             function(d)          return Bridge.UI.Progress(d) end)

-- Dialogs
exports('InputDialog',          function(h, rows, o) return Bridge.UI.InputDialog(h, rows, o) end)
exports('AlertDialog',          function(h, msg, b)  return Bridge.UI.AlertDialog(h, msg, b) end)
exports('ConfirmDialog',        function(d)          return Bridge.UI.ConfirmDialog(d) end)

-- Skill Check / Minigame
exports('SkillCheck',           function(d, k, cb)   return Bridge.UI.SkillCheck(d, k, cb) end)
exports('Minigame',             function(t, cfg, cb) return Bridge.UI.Minigame(t, cfg, cb) end)

-- Tasks
exports('TaskStart',            function(id, d)      return Bridge.UI.TaskStart(id, d) end)
exports('TaskUpdate',           function(id, d)      return Bridge.UI.TaskUpdate(id, d) end)
exports('TaskProgress',         function(id, d)      return Bridge.UI.TaskProgress(id, d) end)
exports('TaskFinish',           function(id, d)      return Bridge.UI.TaskFinish(id, d) end)
exports('TaskCancel',           function(id)         return Bridge.UI.TaskCancel(id) end)

-- Keybinds
exports('SetKeybinds',          function(kb)         return Bridge.UI.SetKeybinds(kb) end)

-- Subtitles
exports('ShowSubtitle',         function(d)          return Bridge.UI.ShowSubtitle(d) end)
exports('HideSubtitle',         function()           return Bridge.UI.HideSubtitle() end)

-- Floating Labels
exports('ShowFloatingLabel',    function(id, d)      return Bridge.UI.ShowFloatingLabel(id, d) end)
exports('UpdateFloatingLabel',  function(id, d)      return Bridge.UI.UpdateFloatingLabel(id, d) end)
exports('HideFloatingLabel',    function(id)         return Bridge.UI.HideFloatingLabel(id) end)
