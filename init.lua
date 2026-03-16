Bridge = _G.dBridge or {}

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
    local args = {...}
    for i = 1, #args do
        args[i] = tostring(args[i])
    end
    print(('^3[div_bridge]^0 %s'):format(table.concat(args, ' ')))
end

local function loadOxLib()
    if _G.lib then return end

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
    if not moduleType then return nil end

    local paths = {
        ('%s/modules/%s/%s/%s.lua'):format(bridgeResName, moduleDir, moduleType, context),
        ('%s/modules/%s/%s/shared.lua'):format(bridgeResName, moduleDir, moduleType),
        ('%s/modules/%s/%s.lua'):format(bridgeResName, moduleDir, moduleType)
    }

    local chunk, finalPath = nil, nil
    for _, path in ipairs(paths) do
        local fileContent = LoadResourceFile(bridgeResName, path:gsub(bridgeResName.."/", ""))
        if fileContent then
            chunk = fileContent
            finalPath = path
            break
        end
    end

    if chunk then
        local fn, err = load(chunk, ('@@%s'):format(finalPath))
        if fn then
            local result = fn()
            rawset(Bridge, moduleName, result or {})
            return result
        else
            print(("^1[div_bridge] Error in module %s (%s): %s^0"):format(moduleName, finalPath, err))
        end
    end
    return nil
end

local function initialize()
    local configContent = LoadResourceFile(bridgeResName, 'config.lua')
    local configFn = configContent and load(configContent, '@@config.lua')
    if configFn then
        local loader = configFn()
        if type(loader) == 'function' then
            Bridge.config = loader(Bridge.config) or Bridge.config
        end
    end

    local detectContent = LoadResourceFile(bridgeResName, 'detection.lua')
    local detectFn = detectContent and load(detectContent, '@@detection.lua')
    if detectFn then
        local detector = detectFn()
        if type(detector) == 'function' then
            Bridge.config = detector(Bridge.config) or Bridge.config
        end
    end

    Bridge.name = currentResName
    Bridge.context = context
    Bridge.debugPrint = debugPrint
    Bridge.loadOxLib = loadOxLib

    for key, value in pairs(Bridge.config) do
        if type(value) == 'string' and key ~= 'Debug' then
            loadModuleFile(key)
        end
    end
end

initialize()

setmetatable(Bridge, {
    __index = function(self, key)
        local mod = loadModuleFile(key)
        if mod then return mod end

        return function()
            if Bridge.config.Debug then
                print(("^1[div_bridge] Attempted to call non-existent module/function: %s^0"):format(key))
            end
        end
    end
})

if Bridge.config.Debug then
    print("^3======= Diversity Bridge Initialized =======^7")
    print("^3Debug Mode: ^2Enabled^7")
    print("^3Framework: ^7" .. Bridge.config.Framework)
    print("^3Inventory: ^7" .. Bridge.config.Inventory)
    print("^3Database: ^7" .. Bridge.config.Database)
    print("^3Interaction: ^7" .. Bridge.config.Interaction)
    print("^3Notification: ^7" .. Bridge.config.Notification)
    print("^3TextUI: ^7" .. Bridge.config.TextUI)
    print("^3======= Diversity Bridge Initialized =======^7")
end

_G.dBridge = Bridge
