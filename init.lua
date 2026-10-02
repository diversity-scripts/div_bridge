local Bridge = _ENV.dBridge or {}
-- Expose immediately in the loading environment (the consumer's globals when
-- init.lua is loaded via load() without a custom _ENV) so module files loaded
-- during initialize() can reference dBridge.* before this file finishes.
_ENV.dBridge = Bridge

if not _VERSION:find('5.4') then
    error('^1Lua 5.4 must be enabled in the resource manifest!^0', 2)
end

local bridgeResName = 'div_bridge'
local currentResName = GetCurrentResourceName()
local context = IsDuplicityVersion() and 'server' or 'client'
local LoadResourceFile = LoadResourceFile

if rawget(Bridge, 'name') == bridgeResName then
    error(("^1Cannot load %s more than once.^0"):format(bridgeResName))
end

msgpack.setoption('ignore_invalid', true)

local function debugPrint(...)
    if not Bridge.config.Debug then return end
    local args = { ... }
    for i = 1, #args do
        args[i] = tostring(args[i])
    end
    print(('^3[div_bridge]^0 %s'):format(table.concat(args, ' ')))
end

-- A soft proxy for missing modules/fields. It is both indexable (returns another
-- proxy, so chained access like dBridge.Foo.Bar never throws) and callable
-- (returns nil with a debug warning). This prevents "attempt to index a function
-- value" errors when callers treat a missing key as a namespace.
---@param name string Dotted path used for the warning message.
---@param onCall? fun(...): any Optional handler invoked when the proxy is called.
local function createDummyProxy(name, onCall)
    return setmetatable({}, {
        __index = function(_, key)
            return createDummyProxy(name .. '.' .. tostring(key), onCall)
        end,
        __call = function(_, ...)
            if onCall then return onCall(...) end
            debugPrint(("^1Attempted to call non-existent module/function: %s^0"):format(name))
            return nil
        end
    })
end

local function loadOxLib()
    if _ENV.lib then return end

    if GetResourceState('ox_lib') ~= 'started' then
        return error('^1[div_bridge] ox_lib must be started before this resource.^0', 0)
    end

    local chunk = LoadResourceFile('ox_lib', 'init.lua')
    if not chunk then
        return error('^1[div_bridge] Failed to load @ox_lib/init.lua^0', 0)
    end

    local fn, err = load(chunk, '@@ox_lib/init.lua', 't')
    if not fn or err then
        return error(('^1[div_bridge] Error loading ox_lib: %s^0'):format(err), 0)
    end

    fn()
end

local function loadModuleFile(moduleName)
    local moduleDir = moduleName:lower()
    local moduleType = Bridge.config[moduleName] or Bridge.config[moduleName:gsub("^%l", string.upper)]

    -- Special handling for UI module: it's a table config, load the router directly
    if moduleName == 'UI' and type(Bridge.config.UI) == 'table' then
        moduleType = nil -- handled below
        local paths = {
            ('modules/ui/%s.lua'):format(context),
            ('modules/ui/shared.lua'),
        }

        local chunk, finalPath = nil, nil
        for _, path in ipairs(paths) do
            local fileContent = LoadResourceFile(bridgeResName, path)
            if fileContent then
                chunk = fileContent
                finalPath = path
                break
            end
        end

        if chunk then
            local fn, err = load(chunk, ('@@%s/%s'):format(bridgeResName, finalPath))
            if fn then
                local result = fn()
                rawset(Bridge, 'UI', result or {})
                debugPrint(('^2Successfully loaded module: UI (unified router)^0'))
                return result
            else
                print(("^1[div_bridge] Error in UI module (%s): %s^0"):format(finalPath, err))
            end
        else
            debugPrint(('^3Could not find UI router file^0'))
        end
        return nil
    end

    if not moduleType then return nil end

    local paths = {
        ('modules/%s/%s/%s.lua'):format(moduleDir, moduleType, context),
        ('modules/%s/%s/shared.lua'):format(moduleDir, moduleType),
        ('modules/%s/%s.lua'):format(moduleDir, moduleType)
    }

    local chunk, finalPath = nil, nil
    for _, path in ipairs(paths) do
        local fileContent = LoadResourceFile(bridgeResName, path)
        if fileContent then
            chunk = fileContent
            finalPath = path
            break
        end
    end

    if chunk then
        local fn, err = load(chunk, ('@@%s/%s'):format(bridgeResName, finalPath))
        if fn then
            local result = fn()
            rawset(Bridge, moduleName, result or {})
            debugPrint(('^2Successfully loaded module: %s (%s)^0'):format(moduleName, moduleType))
            return result
        else
            print(("^1[div_bridge] Error in module %s (%s): %s^0"):format(moduleName, finalPath, err))
        end
    else
        if moduleType ~= 'none' then
            local otherContext = context == 'server' and 'client' or 'server'
            local otherPath = ('modules/%s/%s/%s.lua'):format(moduleDir, moduleType, otherContext)
            if LoadResourceFile(bridgeResName, otherPath) then
                debugPrint(
                    ('^3Module %s (%s) exists only in %s context^0'):format(moduleName, moduleType, otherContext)
                )
            else
                debugPrint(('^3Could not find files for module: %s (%s)^0'):format(moduleName, moduleType))
            end
        else
            debugPrint(('^8Module %s is disabled (none)^0'):format(moduleName))
        end
    end
    return nil
end

local function getModuleStatus(name, moduleType)
    if moduleType == 'none' then
        return "^8DISABLED^0"
    end

    if type(rawget(Bridge, name)) == 'table' then
        return "^2LOADED^0"
    end

    local moduleDir = name:lower()
    local otherContext = context == 'server' and 'client' or 'server'
    local otherPath = ('modules/%s/%s/%s.lua'):format(moduleDir, moduleType, otherContext)
    if LoadResourceFile(bridgeResName, otherPath) then
        return otherContext == 'client' and "^3CLIENT_ONLY^0" or "^3SERVER_ONLY^0"
    end

    return "^1MISSING/ERROR^0"
end

local function hasModule(name)
    local key = tostring(name)
    local mod = rawget(Bridge, key) or loadModuleFile(key)
    return type(mod) == 'table'
end

-- Returns the loaded Framework module, erroring if it isn't a valid table.
-- Shared by inventory/banking/ui framework adapters so they don't each copy
-- their own getFramework() helper.
---@param label? string Prefix for the error message (e.g. 'Inventory').
---@return table framework
local function getFramework(label)
    local framework = Bridge.Framework
    if type(framework) ~= 'table' then
        error(
            ('%s: dBridge.Framework failed to load or is invalid. Please check your config.'):format(
                label or 'Framework'
            ),
            2
        )
    end
    return framework
end

-- Strips the bridge's custom text formatting (color tags, bold, keybind hints)
-- so plain-text UI providers get clean strings. Shared by every UI adapter that
-- previously copied its own sanitize() helper.
---@param text any
---@return string
local function sanitize(text)
    if type(text) ~= 'string' then return text or '' end
    text = text:gsub('<color:[^>]*>(.-)</color>', '%1') -- <color:#hex>...</color>
    text = text:gsub('|#[%x]+|(.-)|', '%1') -- |#hex|text|
    text = text:gsub('%*(.-)%*', '%1') -- *bold*
    text = text:gsub('~([^~]+)~', '[%1]') -- ~KEY~ keybind hints
    return text
end

local function loadConfig(existing)
    local chunk = LoadResourceFile(bridgeResName, 'lib/loadConfig.lua')
    local fn = chunk and load(chunk, '@@div_bridge/lib/loadConfig.lua')
    return fn and fn()(existing) or existing or {}
end

local function initialize()
    Bridge.config = loadConfig(Bridge.config)

    Bridge.name = currentResName
    Bridge.context = context
    Bridge.debugPrint = debugPrint
    Bridge.loadOxLib = loadOxLib
    Bridge.HasModule = hasModule
    Bridge.getFramework = getFramework
    Bridge.sanitize = sanitize

    -- Explicitly load the Framework module first so other modules can rely on it during their initialization
    if Bridge.config.Framework and Bridge.config.Framework ~= 'none' then
        loadModuleFile('Framework')
    end

    for key, value in pairs(Bridge.config) do
        if type(value) == 'string' and key ~= 'Debug' and key ~= 'Language' and key ~= 'Framework' then
            loadModuleFile(key)
        end
    end

    -- Load the unified UI module if Config.UI is defined
    if type(Bridge.config.UI) == 'table' then
        if currentResName == bridgeResName then
            loadModuleFile('UI')
        else
            if GetResourceState(bridgeResName) ~= 'started' then
                print('^1[div_bridge] div_bridge must be started before this resource for UI to work.^0')
            else
                local exp = exports[bridgeResName]
                local contextCallbacks = {}

                -- Helper: strip non-serializable values (functions) from context
                -- data before passing over the export boundary, storing callbacks
                -- locally so they survive the msgpack round-trip.
                local function prepareContext(data)
                    if type(data) ~= 'table' then return data end
                    local stripped = {}
                    for k, v in pairs(data) do
                        if k ~= 'options' and k ~= 'onExit' and k ~= 'onBack' then
                            stripped[k] = v
                        end
                    end
                    -- Store top-level callbacks
                    if data.onExit or data.onBack then
                        contextCallbacks[data.id] = contextCallbacks[data.id] or {}
                        contextCallbacks[data.id]._onExit = data.onExit
                        contextCallbacks[data.id]._onBack = data.onBack
                    end
                    -- Strip functions from options
                    if data.options then
                        stripped.options = {}
                        for i, opt in ipairs(data.options) do
                            local strippedOpt = {}
                            for k, v in pairs(opt) do
                                if type(v) ~= 'function' then
                                    strippedOpt[k] = v
                                end
                            end
                            stripped.options[i] = strippedOpt
                            -- Store callbacks keyed by menuId + index
                            if opt.onSelect then
                                contextCallbacks[data.id] = contextCallbacks[data.id] or {}
                                contextCallbacks[data.id][i] = opt.onSelect
                            end
                        end
                    end
                    return stripped
                end

                -- Listen for click events fired back from div_bridge
                AddEventHandler('div_bridge:ui:contextClick', function(menuId, index, args)
                    local cbs = contextCallbacks[menuId]
                    if cbs and cbs[index] then
                        cbs[index](args)
                    end
                end)

                AddEventHandler('div_bridge:ui:contextExit', function(menuId)
                    local cbs = contextCallbacks[menuId]
                    if cbs and cbs._onExit then cbs._onExit() end
                end)

                AddEventHandler('div_bridge:ui:contextBack', function(menuId)
                    local cbs = contextCallbacks[menuId]
                    if cbs and cbs._onBack then cbs._onBack() end
                end)

                rawset(
                    Bridge,
                    'UI',
                    setmetatable({}, {
                        __index = function(_, fn)
                            -- Return a callable proxy: calling it forwards to the
                            -- div_bridge export; indexing it further (e.g. mistaking
                            -- a UI method for a namespace) degrades gracefully rather
                            -- than throwing "attempt to index a function value".
                            return createDummyProxy('UI.' .. tostring(fn), function(...)
                                if fn == 'RegisterContext' then
                                    local data = ...
                                    local prepared = prepareContext(data)
                                    return exp:RegisterContext(prepared)
                                end
                                return exp[fn](exp, ...)
                            end)
                        end
                    })
                )
                if Bridge.config.Debug then
                    print('^3[div_bridge] UI proxy installed for external resource: ' .. currentResName .. '^0')
                end
            end
        end
    end
end

initialize()

setmetatable(Bridge, {
    __index = function(self, key)
        local mod = loadModuleFile(key)
        if mod then return mod end
        return createDummyProxy(tostring(key))
    end
})

if Bridge.config.Debug then
    print("^3======= Diversity Bridge Initialized =======^7")
    print("^3Debug Mode: ^2Enabled^7")
    print("^3Framework: ^7" .. tostring(Bridge.config.Framework or 'none'))
    print("^3Inventory: ^7" .. tostring(Bridge.config.Inventory or 'none'))
    print("^3Database: ^7" .. tostring(Bridge.config.Database or 'none'))
    print("^3Interaction: ^7" .. tostring(Bridge.config.Interaction or 'none'))
    if type(Bridge.config.UI) == 'table' then
        print("^3UI Module:^7")
        for component, provider in pairs(Bridge.config.UI) do
            print(("^3  %s: ^7%s"):format(component, tostring(provider)))
        end
    end
    print("^3Bank: ^7" .. tostring(Bridge.config.Banking or 'none'))
    print("^3======= Diversity Bridge Initialized =======^7")
end

RegisterCommand('bridgestatus', function(source, args, rawCommand)
    local prefix = "^3[div_bridge]^0"
    print(prefix .. " ^2=== Diversity Bridge Status ===^0")
    print(
        prefix
            .. " Context: ^5" .. context .. "^0 | Debug: " .. (Bridge.config.Debug and "^2Enabled^0" or "^8Disabled^0")
    )

    for key, value in pairs(Bridge.config) do
        if type(value) == 'string' and key ~= 'Debug' and key ~= 'Language' then
            local status = getModuleStatus(key, value)
            print(prefix .. string.format(" %s: ^7%s^0 [%s]", key, value, status))
        elseif type(value) == 'table' and key == 'UI' then
            local uiStatus = type(rawget(Bridge, 'UI')) == 'table' and "^2LOADED^0" or "^1MISSING/ERROR^0"
            print(prefix .. string.format(" UI: ^7unified^0 [%s]", uiStatus))
            for component, provider in pairs(value) do
                print(prefix .. string.format("   %s: ^7%s^0", component, provider))
            end
        end
    end
    print(prefix .. " ^2===============================^0")
end, true)
