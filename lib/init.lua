local Lib = _ENV.dLib or {}
-- Expose immediately in the loading environment (the consumer's globals when
-- lib/init.lua is loaded via load() without a custom _ENV) so lib module files
-- can reference dLib.* while loading.
_ENV.dLib = Lib

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
        ('lib/%s/%s.lua'):format(moduleName, context), -- lib/requestModel/client.lua
        ('lib/%s/shared.lua'):format(moduleName),      -- lib/table/shared.lua
        ('lib/%s.lua'):format(moduleName)              -- lib/requestModel.lua (fallback)
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

local function loadConfig(existing)
    local chunk = LoadResourceFile(bridgeResName, 'lib/loadConfig.lua')
    local fn = chunk and load(chunk, '@@div_bridge/lib/loadConfig.lua')
    return fn and fn()(existing) or existing or {}
end

local function initialize()
    Lib.config = loadConfig(Lib.config)

    -- Set name/context so the double-load guard above is effective, mirroring
    -- init.lua (Bridge). Uses the loading resource's name, so external consumers
    -- get their own name and only a true re-load within div_bridge trips it.
    Lib.name = GetCurrentResourceName()
    Lib.context = context
end

initialize()

-- ox_lib-style resolution: each key maps 1:1 to a module folder under lib/.
-- The module's returned value is stored directly on dLib:
--   * returns a function -> dLib.requestModel(...) is callable directly
--   * returns a table    -> dLib.table.contains(...) is a namespace
-- Module keys are lowercase-first (dLib.math, dLib.requestModel), matching the
-- ox_lib convention. No flattening and no cross-module scanning. Unknown keys nil.
setmetatable(Lib, {
    __index = function(self, key)
        local module = loadLibModule(key)
        rawset(self, key, module)
        return module
    end
})

-- NOTE: we deliberately do NOT publish bare `cache` or `require` globals.
-- ox_lib owns those names (_ENV.cache / _ENV.require) when loaded, and clobbering
-- them risks breaking modules that rely on them (e.g. ox_core's
-- `require '@ox_core/lib/init'`). Use dLib.cache and dLib.require instead.
