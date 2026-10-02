-------------------------------------------------------------------------------
-- UI Module Router (Client)
-- Loads per-component adapters based on Config.UI settings.
-- Falls back to 'internal' when a provider doesn't support a component.
-------------------------------------------------------------------------------

local UI = {}

local bridgeResName = 'div_bridge'
local LoadResourceFile = LoadResourceFile
local context = 'client'

local uiConfig = dBridge.config.UI or {}

-------------------------------------------------------------------------------
-- Text Sanitizer
-- Strips custom formatting (Markdown bold, ~KEY~, <color:...>, |#hex|text|)
-- for adapters that don't support rich text.
-------------------------------------------------------------------------------
UI.Sanitize = dBridge.sanitize

-------------------------------------------------------------------------------
-- Internal UI loader (loads modules/ui/internal/client.lua once, caches it)
-------------------------------------------------------------------------------
local internalUI = nil

local function getInternalUI()
    if internalUI then return internalUI end
    local chunk = LoadResourceFile(bridgeResName, 'modules/ui/internal/client.lua')
    if not chunk then
        error('^1[div_bridge] Failed to load internal UI (modules/ui/internal/client.lua)^0', 2)
    end
    local fn, err = load(chunk, '@@div_bridge/modules/ui/internal/client.lua')
    if not fn then
        error(('^1[div_bridge] Error loading internal UI: %s^0'):format(err), 2)
    end
    internalUI = fn()
    return internalUI
end

-------------------------------------------------------------------------------
-- Adapter loader
-- Searches for the provider in: providers/multi/, providers/notification/,
-- providers/textui/ — in that order.
-- Returns nil if no file is found (triggers fallback to internal).
-------------------------------------------------------------------------------
local adapterCache = {}

local function loadAdapter(provider)
    if provider == 'internal' or provider == 'none' then return nil end
    if adapterCache[provider] ~= nil then return adapterCache[provider] end

    local searchPaths = {
        ('modules/ui/providers/multi/%s/%s.lua'):format(provider, context),
        ('modules/ui/providers/notification/%s/%s.lua'):format(provider, context),
        ('modules/ui/providers/textui/%s/%s.lua'):format(provider, context),
    }

    local chunk, finalPath = nil, nil
    for _, path in ipairs(searchPaths) do
        local fileContent = LoadResourceFile(bridgeResName, path)
        if fileContent then
            chunk = fileContent
            finalPath = path
            break
        end
    end

    if not chunk then
        adapterCache[provider] = false
        return nil
    end

    local fn, err = load(chunk, ('@@%s/%s'):format(bridgeResName, finalPath))
    if not fn then
        print(('^1[div_bridge] Error loading UI adapter %s: %s^0'):format(provider, err))
        adapterCache[provider] = false
        return nil
    end

    local result = fn()
    adapterCache[provider] = result or false
    return result or nil
end

-------------------------------------------------------------------------------
-- Provider resolution with fallback
-- If the chosen provider doesn't have an adapter file, fall back to internal.
-------------------------------------------------------------------------------
local function resolveProvider(component)
    local provider = uiConfig[component]
    if not provider or provider == 'none' then return nil, 'none' end
    if provider == 'internal' then return getInternalUI(), 'internal' end

    local adapter = loadAdapter(provider)
    if adapter then
        return adapter, provider
    end

    -- Fallback: provider doesn't support this component
    dBridge.debugPrint(('^3[UI] %s: provider "%s" has no adapter, falling back to internal^0'):format(component, provider))
    return getInternalUI(), 'internal'
end

-------------------------------------------------------------------------------
-- Resolve adapters for each component
-------------------------------------------------------------------------------
local notifyAdapter, notifyProvider = resolveProvider('Notification')
local textUIAdapter, textUIProvider = resolveProvider('TextUI')
local progressAdapter, progressProvider = resolveProvider('ProgressBar')
local contextAdapter, contextProvider = resolveProvider('ContextMenu')
local inputAdapter, inputProvider = resolveProvider('InputDialog')
local alertAdapter, alertProvider = resolveProvider('AlertDialog')
local confirmAdapter, confirmProvider = resolveProvider('ConfirmDialog')
local skillCheckAdapter, skillCheckProvider = resolveProvider('SkillCheck')

-- These are always internal (no external adapters exist)
local internal = getInternalUI()

dBridge.debugPrint('[div_bridge - UI] Router loaded. Providers: Notification=' .. notifyProvider .. ', ContextMenu=' .. contextProvider .. ', TextUI=' .. textUIProvider .. ', ProgressBar=' .. progressProvider)

-- Warn if any critical adapter failed to load (always shown, it's an error condition)
if not contextAdapter then
    print('^1[div_bridge - UI] WARNING: ContextMenu adapter failed to load (provider: "' .. contextProvider .. '"). RegisterContext/ShowContext will not work.^0')
end

-------------------------------------------------------------------------------
-- Public API: Notification
-------------------------------------------------------------------------------

-- Resolved provider per component (after auto-detection and internal fallback).
-- Components with no external adapter are always 'internal'.
local resolvedProviders = {
    Notification = notifyProvider,
    TextUI = textUIProvider,
    ProgressBar = progressProvider,
    ContextMenu = contextProvider,
    InputDialog = inputProvider,
    AlertDialog = alertProvider,
    ConfirmDialog = confirmProvider,
    SkillCheck = skillCheckProvider,
}

---Returns the resolved provider name for a UI component (e.g. 'internal',
---'ox_lib', 'standalone'). Unlike the config value, this reflects the actual
---provider after 'auto' detection and any fallback to 'internal'.
---@param component string Component name, e.g. 'TextUI', 'Notification'.
---@return string provider
UI.GetProvider = function(component)
    return resolvedProviders[component] or 'internal'
end

---@param data {type?: string, title?: string, text: string, duration?: number, actions?: table}
---@return number|nil notificationId
UI.Notify = function(data)
    if not notifyAdapter then return nil end
    if notifyProvider == 'internal' then
        return notifyAdapter.Notify(data)
    else
        if notifyAdapter.Notify then
            return notifyAdapter.Notify(data)
        end
    end
end

---@param id number
---@param data {type?: string, title?: string, text?: string, duration?: number}
UI.NotifyUpdate = function(id, data)
    if not notifyAdapter then return end
    if notifyProvider == 'internal' and notifyAdapter.NotifyUpdate then
        notifyAdapter.NotifyUpdate(id, data)
    end
    -- External adapters typically don't support live updates; silently drop.
end

---@param id number
UI.NotifyClose = function(id)
    if not notifyAdapter then return end
    if notifyProvider == 'internal' and notifyAdapter.NotifyClose then
        notifyAdapter.NotifyClose(id)
    end
end

-------------------------------------------------------------------------------
-- Public API: TextUI
-------------------------------------------------------------------------------

---@param id string Unique identifier for this text UI instance
---@param data {text: string, icon?: string, position?: string}|string Text data or plain string
UI.ShowTextUI = function(id, data)
    if not textUIAdapter then return end
    if textUIProvider == 'internal' then
        internal.ShowTextUI(id, type(data) == 'string' and { text = data } or data)
    else
        -- External adapters only support a single text UI, ignore the ID
        local text = type(data) == 'string' and data or (data and data.text or '')
        local cleaned = dBridge.sanitize(text)
        if textUIAdapter.ShowTextUI then
            textUIAdapter.ShowTextUI(cleaned)
        end
    end
end

---@param id? string Identifier of the text UI to hide (ignored by external adapters)
UI.HideTextUI = function(id)
    if not textUIAdapter then return end
    if textUIProvider == 'internal' then
        internal.HideTextUI(id)
    else
        if textUIAdapter.HideTextUI then textUIAdapter.HideTextUI() end
    end
end

-------------------------------------------------------------------------------
-- Public API: Progress
-------------------------------------------------------------------------------

---@param data {type?: 'bar'|'circle', duration: number, label?: string, subtitle?: string, icon?: string, colorScheme?: string, stages?: number, activeStage?: number, cancelKey?: string, position?: string}
---@return boolean completed
UI.Progress = function(data)
    if not progressAdapter then return false end
    if progressProvider == 'internal' then
        return progressAdapter.Progress(data)
    else
        if progressAdapter.Progress then
            return progressAdapter.Progress(data)
        end
    end
    return false
end

-------------------------------------------------------------------------------
-- Public API: Context Menu
-------------------------------------------------------------------------------

---@param data {id: string, title: string, menu?: string, options: table[]}
UI.RegisterContext = function(data)
    if not contextAdapter then
        print('^1[div_bridge - UI] RegisterContext failed: ContextMenu adapter is nil. Check Config.UI.ContextMenu in config_ui.lua (current provider: "' .. contextProvider .. '")^0')
        return
    end
    if contextProvider == 'internal' then
        contextAdapter.RegisterContext(data)
    else
        if contextAdapter.RegisterContext then
            contextAdapter.RegisterContext(data)
        else
            print('^3[div_bridge - UI] RegisterContext: provider "' .. contextProvider .. '" has no RegisterContext function.^0')
        end
    end
end
---@param id string
UI.ShowContext = function(id)
    if not contextAdapter then
        print('^1[div_bridge - UI] ShowContext failed: ContextMenu adapter is nil. Check Config.UI.ContextMenu in config_ui.lua (current provider: "' .. contextProvider .. '")^0')
        return
    end
    if contextProvider == 'internal' then
        contextAdapter.ShowContext(id)
    else
        if contextAdapter.ShowContext then
            contextAdapter.ShowContext(id)
        else
            print('^3[div_bridge - UI] ShowContext: provider "' .. contextProvider .. '" has no ShowContext function.^0')
        end
    end
end

UI.HideContext = function()
    if not contextAdapter then return end
    if contextProvider == 'internal' then
        contextAdapter.HideContext()
    else
        if contextAdapter.HideContext then
            contextAdapter.HideContext()
        end
    end
end

---@return string|nil
UI.GetOpenContextMenu = function()
    if not contextAdapter then return nil end
    if contextProvider == 'internal' then
        return contextAdapter.GetOpenContextMenu()
    end
    return nil
end

---@param id string
---@param data table
UI.UpdateContext = function(id, data)
    if not contextAdapter then return end
    if contextProvider == 'internal' then
        contextAdapter.UpdateContext(id, data)
    else
        if contextAdapter.UpdateContext then
            contextAdapter.UpdateContext(id, data)
        end
    end
end

---@param id string
---@param data table
UI.UpdateTextUI = function(id, data)
    if not contextAdapter then return end
    if contextProvider == 'internal' then
        internal.UpdateTextUI(id, data)
    end
end

-------------------------------------------------------------------------------
-- Public API: Input Dialog
-------------------------------------------------------------------------------

---@param heading string
---@param rows table[]
---@param options? table
---@return table|nil
UI.InputDialog = function(heading, rows, options)
    if not inputAdapter then return nil end
    if inputProvider == 'internal' then
        return inputAdapter.InputDialog(heading, rows, options)
    else
        if inputAdapter.InputDialog then
            return inputAdapter.InputDialog(heading, rows, options)
        end
    end
    return nil
end

-------------------------------------------------------------------------------
-- Public API: Alert Dialog
-------------------------------------------------------------------------------

---@param heading string
---@param message string
---@param buttons? string[]
---@return boolean
UI.AlertDialog = function(heading, message, buttons)
    if not alertAdapter then return false end
    if alertProvider == 'internal' then
        return alertAdapter.AlertDialog(heading, message, buttons)
    else
        if alertAdapter.AlertDialog then
            return alertAdapter.AlertDialog(heading, message, buttons)
        end
    end
    return false
end

-------------------------------------------------------------------------------
-- Public API: Confirm Dialog
-------------------------------------------------------------------------------

---@param data table
---@return {confirmed: boolean, value: string|nil}
UI.ConfirmDialog = function(data)
    if not confirmAdapter then return { confirmed = false } end
    if confirmProvider == 'internal' then
        return confirmAdapter.ConfirmDialog(data)
    else
        if confirmAdapter.ConfirmDialog then
            return confirmAdapter.ConfirmDialog(data)
        end
    end
    return { confirmed = false }
end

-------------------------------------------------------------------------------
-- Public API: Skill Check
-------------------------------------------------------------------------------

---@param difficulty string|table
---@param key? string
---@param callback fun(success: boolean)
UI.SkillCheck = function(difficulty, key, callback)
    if not skillCheckAdapter then
        if callback then callback(false) end
        return
    end
    if skillCheckProvider == 'internal' then
        skillCheckAdapter.SkillCheck(difficulty, key, callback)
    else
        if skillCheckAdapter.SkillCheck then
            skillCheckAdapter.SkillCheck(difficulty, key, callback)
        end
    end
end

-------------------------------------------------------------------------------
-- Public API: Minigame (unified)
-------------------------------------------------------------------------------

---@param minigameType string Minigame type identifier
---@param config string|table Preset name or difficulty config table
---@param callback fun(success: boolean)
UI.Minigame = function(minigameType, config, callback)
    internal.Minigame(minigameType, config, callback)
end

-------------------------------------------------------------------------------
-- Public API: Internal-only components (always use built-in NUI)
-------------------------------------------------------------------------------

-- Tasks
UI.TaskStart = function(id, data) internal.TaskStart(id, data) end
UI.TaskUpdate = function(id, data) internal.TaskUpdate(id, data) end
UI.TaskProgress = function(id, data) return internal.TaskProgress(id, data) end
UI.TaskFinish = function(id, data) internal.TaskFinish(id, data) end
UI.TaskCancel = function(id) internal.TaskCancel(id) end

-- Keybinds
UI.SetKeybinds = function(keybinds) internal.SetKeybinds(keybinds) end

-- Subtitles
UI.ShowSubtitle = function(data) internal.ShowSubtitle(data) end
UI.HideSubtitle = function() internal.HideSubtitle() end

-- Floating Labels
UI.ShowFloatingLabel = function(id, data) internal.ShowFloatingLabel(id, data) end
UI.UpdateFloatingLabel = function(id, data) internal.UpdateFloatingLabel(id, data) end
UI.HideFloatingLabel = function(id) internal.HideFloatingLabel(id) end

return UI
