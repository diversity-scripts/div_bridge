-------------------------------------------------------------------------------
-- UI Module Router (Server)
-- Loads per-component adapters based on Config.UI settings.
-- Falls back to 'internal' when a provider doesn't support a component.
-------------------------------------------------------------------------------

local UI = {}

local bridgeResName = 'div_bridge'
local LoadResourceFile = LoadResourceFile
local context = 'server'

local uiConfig = dBridge.config.UI or {}

-------------------------------------------------------------------------------
-- Text Sanitizer (shared bridge helper)
-------------------------------------------------------------------------------
UI.Sanitize = dBridge.sanitize

-------------------------------------------------------------------------------
-- Internal UI loader (loads modules/ui/internal/server.lua once)
-------------------------------------------------------------------------------
local internalUI = nil

local function getInternalUI()
    if internalUI then return internalUI end
    local chunk = LoadResourceFile(bridgeResName, 'modules/ui/internal/server.lua')
    if not chunk then
        error('^1[div_bridge] Failed to load internal UI server (modules/ui/internal/server.lua)^0', 2)
    end
    local fn, err = load(chunk, '@@div_bridge/modules/ui/internal/server.lua')
    if not fn then
        error(('^1[div_bridge] Error loading internal UI server: %s^0'):format(err), 2)
    end
    internalUI = fn()
    return internalUI
end

-------------------------------------------------------------------------------
-- Adapter loader
-------------------------------------------------------------------------------
local adapterCache = {}

local function loadAdapter(provider)
    if provider == 'internal' or provider == 'none' then return nil end
    if adapterCache[provider] ~= nil then return adapterCache[provider] end

    local searchPaths = {
        ('modules/ui/providers/multi/%s/%s.lua'):format(provider, context),
        ('modules/ui/providers/notification/%s/%s.lua'):format(provider, context),
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
        print(('^1[div_bridge] Error loading UI server adapter %s: %s^0'):format(provider, err))
        adapterCache[provider] = false
        return nil
    end

    local result = fn()
    adapterCache[provider] = result or false
    return result or nil
end

-------------------------------------------------------------------------------
-- Provider resolution with fallback
-------------------------------------------------------------------------------
local function resolveProvider(component)
    local provider = uiConfig[component]
    if not provider or provider == 'none' then return nil, 'none' end
    if provider == 'internal' then return getInternalUI(), 'internal' end

    local adapter = loadAdapter(provider)
    if adapter then
        return adapter, provider
    end

    dBridge.debugPrint(('^3[UI Server] %s: provider "%s" has no server adapter, falling back to internal^0'):format(component, provider))
    return getInternalUI(), 'internal'
end

-------------------------------------------------------------------------------
-- Resolve notification adapter
-------------------------------------------------------------------------------
local notifyAdapter, notifyProvider = resolveProvider('Notification')
local internal = getInternalUI()

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

---Returns the resolved provider name for a UI component. Server-side only the
---Notification provider is resolved with fallback; other components report their
---configured value ('internal' when unset/'auto', since they are internal-only
---on the server).
---@param component string Component name, e.g. 'Notification'.
---@return string provider
UI.GetProvider = function(component)
    if component == 'Notification' then
        return notifyProvider
    end
    local provider = uiConfig[component]
    if not provider or provider == 'auto' or provider == 'none' then
        return 'internal'
    end
    return provider
end

---@param target number Player server ID
---@param data table Notification data
UI.Notify = function(target, data)
    if not notifyAdapter then return end
    if notifyProvider == 'internal' then
        internal.ToPlayer(target, data)
    else
        if notifyAdapter.Notify then
            notifyAdapter.Notify(target, data)
        end
    end
end

---@param target number Player server ID
---@param data table Notification data
UI.ToPlayer = function(target, data)
    UI.Notify(target, data)
end

---@param data table Notification data
UI.ToAllPlayers = function(data)
    if notifyProvider == 'internal' then
        internal.ToAllPlayers(data)
    else
        for _, playerId in ipairs(GetPlayers()) do
            UI.Notify(tonumber(playerId), data)
        end
    end
end

---@param job string Job name
---@param data table Notification data
UI.ToJob = function(job, data)
    if notifyProvider == 'internal' then
        internal.ToJob(job, data)
    else
        if not dBridge or not dBridge.Framework then
            print('^1[div_bridge - UI] Error: ToJob requires a loaded Framework module.^0')
            return
        end
        local fw = dBridge.Framework
        if not fw.GetPlayerJob then
            print('^1[div_bridge - UI] Error: Framework module does not support GetPlayerJob.^0')
            return
        end
        for _, playerId in ipairs(GetPlayers()) do
            local src = tonumber(playerId)
            local currentJob = fw.GetPlayerJob(src)
            if currentJob and currentJob.name == job then
                UI.Notify(src, data)
            end
        end
    end
end

---@param permission string ACE permission
---@param data table Notification data
UI.ToACEPermission = function(permission, data)
    if notifyProvider == 'internal' then
        internal.ToACEPermission(permission, data)
    else
        for _, playerId in ipairs(GetPlayers()) do
            if IsPlayerAceAllowed(playerId, permission) then
                UI.Notify(tonumber(playerId), data)
            end
        end
    end
end

return UI
