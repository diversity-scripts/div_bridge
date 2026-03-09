Lib = _G.dLib or {}

local bridgeResName = 'div_bridge'
local context = IsDuplicityVersion() and 'server' or 'client'

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
