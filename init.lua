Bridge = {}

if not _VERSION:find('5.4') then
    error('Lua 5.4 must be enabled in the resource manifest!', 2)
end

local resourceName = GetCurrentResourceName()
local bridgeResName = 'div_bridge'

-- Prevent Duplicate Loading
if Bridge and Bridge.name == bridgeResName then
    error(("Cannot load %s more than once.\n\tRemove any duplicate entries from '@%s/fxmanifest.lua'"):format(bridgeResName, resourceName))
end

if GetResourceState(bridgeResName) ~= 'started' and resourceName ~= bridgeResName then
    error('^1div_bridge must be started before this resource.^0', 0)
end

msgpack.setoption('ignore_invalid', true)

local LoadResourceFile = LoadResourceFile
local context = IsDuplicityVersion() and 'server' or 'client'

local function loadConfig(path)
    local filePath = path:gsub('%.', '/') .. '.lua'
    local fileContent = LoadResourceFile(bridgeResName, filePath)

    if not fileContent then
        if path == 'config' then
            error(("^1[div_bridge] Unable to load config file: %s from %s^0"):format(filePath, bridgeResName), 2)
        end
        return nil
    end

    local fn, err = load(fileContent, ('@@%s/%s'):format(bridgeResName, filePath))
    if not fn or err then
        error(("^1[div_bridge] Syntax error in file %s: %s^0"):format(filePath, err), 2)
        return nil
    end

    local result = fn()

    if not result and path == 'config' then
        error(("^1[div_bridge] Config file %s returned nil (empty or no return)^0"):format(filePath), 2)
    end

    return result
end

local config = loadConfig('config')
local detect = loadConfig('detection')

if detect then
    local newConfig = detect(config)
    if newConfig then
        config = newConfig
    else
        print('^1[div_bridge] Detection module returned nil! Using default config.^0')
    end
end

local function noop() end

local function loadModule(self, moduleName)
    -- Normalize module name to lower case for folder structure (e.g. Framework -> framework)
    local moduleDir = moduleName:lower()

    -- Check if the module is defined in config (using PascalCase key from config)
    -- We assume the user requests Bridge.Framework, so moduleName is "Framework"
    -- But if they request Bridge.framework, we should probably handle that too.
    -- To be safe, we try both, but prefer the Config key which is PascalCase.
    local moduleType = config[moduleName] or config[moduleName:gsub("^%l", string.upper)]

    if not moduleType then
        -- Silent return allows it to fall through to exports
        return
    end

    local dir = ('modules/%s'):format(moduleDir)
    local path = ('%s/%s/%s.lua'):format(dir, context, moduleType)
    local chunk = LoadResourceFile(bridgeResName, path)

    -- Fallback for shared modules (if client/server specific file missing)
    if not chunk and context == 'client' then
        path = ('%s/%s.lua'):format(dir, moduleType)
        chunk = LoadResourceFile(bridgeResName, path)
    end

    if not chunk then
        return error(('^1[div_bridge] Module file not found: %s^0'):format(path), 2)
    end

    local fn, err = load(chunk, ('@@%s/%s'):format(bridgeResName, path))

    if not fn or err then
        return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
    end

    -- Execute the chunk
    local result = fn()

    -- Cache the result so we don't load it again
    rawset(self, moduleName, result or noop)

    return result or noop
end

local function call(self, index)
    -- Try to load the module
    local module = loadModule(self, index)

    if module then
        return module
    end

    -- Export Fallback
    local success, result = pcall(function() return exports[resourceName][index] end)
    if success and result then
        rawset(self, index, result)
        return result
    end

    -- If nothing found, return a safe noop to prevent crashes
    return noop
end

local function loadLib()
    print('Loading ox_lib...')
    if _G.lib then return print('ox_lib already loaded') end

    if GetResourceState('ox_lib') ~= 'started' then
        return error('^1[div_bridge] ox_lib must be started before this resource.^0', 0)
    end

    local chunk = LoadResourceFile('ox_lib', 'init.lua')
    if not chunk then
        return error('^1[div_bridge] Failed to load resource file @ox_lib/init.lua^0', 0)
    end

    local fn, err = load(chunk, '@@ox_lib/init.lua', 't')
    if not fn or err then
        return error(('^1[div_bridge] Error loading ox_lib: %s^0'):format(err), 0)
    end

    fn()
end

-- Setup the Bridge Table
local bridge = setmetatable({
    name = resourceName,
    context = context,
    config = config,
    loadLib = loadLib
}, {
    __index = call
})

-- Global assignment
Bridge = bridge

print("^3======= Diversity Bridge Initialized =======^7")
print("^3Framework: ^7" .. config.Framework)
print("^3Inventory: ^7" .. config.Inventory)
print("^3Database: ^7" .. config.Database)
print("^3Interaction: ^7" .. config.Interaction)
print("^3Notification: ^7" .. config.Notification)
print("^3TextUI: ^7" .. config.TextUI)
print("^3======= Diversity Bridge Initialized =======^7")