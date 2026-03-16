Lib = _G.dLib or {}

if not _VERSION:find('5.4') then
    error('^1Lua 5.4 must be enabled in the resource manifest!^0', 2)
end

local bridgeResName = 'div_bridge'
local context = IsDuplicityVersion() and 'server' or 'client'
local LoadResourceFile = LoadResourceFile

if rawget(Lib, 'name') == bridgeResName then
    error(("^1Cannot load %s more than once.^0"):format(bridgeResName))
end

local function loadLibModule(moduleName)
    local chunk, finalPath

    local paths = {
        ('lib/%s/%s.lua'):format(moduleName, context), -- lib/math/client.lua
        ('lib/%s/shared.lua'):format(moduleName),      -- lib/math/shared.lua
        ('lib/%s.lua'):format(moduleName)              -- lib/math.lua (fallback)
    }

    for _, path in ipairs(paths) do
        local fileContent = LoadResourceFile(bridgeResName, path)
        if fileContent then
            chunk = fileContent
            finalPath = path
            break
        end
    end

    if not chunk then return nil end

    local fn, err = load(chunk, ('@@%s/%s'):format(bridgeResName, finalPath))
    if not fn or err then
        error(("^1[div_bridge] Error loading lib module %s: %s^0"):format(moduleName, err or "Unknown error"), 2)
    end

    return fn()
end

local function initialize()
    local configContent = LoadResourceFile(bridgeResName, 'config.lua')
    local configFn = configContent and load(configContent, '@@config.lua')
    if configFn then
        local loader = configFn()
        if type(loader) == 'function' then
            Lib.config = loader(Lib.config) or Lib.config
        end
    end

    local detectContent = LoadResourceFile(bridgeResName, 'detection.lua')
    local detectFn = detectContent and load(detectContent, '@@detection.lua')
    if detectFn then
        local detector = detectFn()
        if type(detector) == 'function' then
            Lib.config = detector(Lib.config) or Lib.config
        end
    end

    Bridge.name = currentResName
    Bridge.context = context
end

initialize()

setmetatable(Lib, {
    __index = function(self, key)
        local lower = tostring(key):lower()
        local existing = rawget(self, lower)
        if existing ~= nil then
            rawset(self, key, existing)
            return existing
        end
        local module = loadLibModule(lower)
        if module then
            rawset(self, lower, module)
            rawset(self, key, module)
            return module
        end

        return nil
    end
})

_G.dLib = Lib
