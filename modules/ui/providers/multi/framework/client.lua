-------------------------------------------------------------------------------
-- Framework UI Adapter (Client)
-- Uses the loaded framework's built-in Notify/TextUI functions.
-------------------------------------------------------------------------------

local Adapter = {}

local framework = dBridge.getFramework('UI Framework Adapter')

-------------------------------------------------------------------------------
-- Notification
-------------------------------------------------------------------------------

---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(data)
    assert(framework.Notify, 'Your framework does not provide a client-side "Notify" function.')
    framework.Notify(dBridge.sanitize(data.text or data.message or ''), data.type, data.duration)
end

-------------------------------------------------------------------------------
-- TextUI
-------------------------------------------------------------------------------

---@param text string
Adapter.ShowTextUI = function(text)
    assert(framework.ShowTextUI, 'Your framework does not provide a client-side "ShowTextUI" function.')
    framework:ShowTextUI(dBridge.sanitize(text))
end

Adapter.HideTextUI = function()
    assert(framework.HideTextUI, 'Your framework does not provide a client-side "HideTextUI" function.')
    framework:HideTextUI()
end

return Adapter
