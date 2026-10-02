-------------------------------------------------------------------------------
-- Shared config loader
-- Loads config/config.lua then runs detection.lua over it, returning the final
-- config table. Used by both init.lua (Bridge) and lib/init.lua (Lib) so the
-- load+detect sequence isn't duplicated. Returns a single function.
-------------------------------------------------------------------------------

local bridgeResName = 'div_bridge'

---@param existing? table Existing config to fall back to.
---@return table config
return function(existing)
    local config = existing or {}

    local configContent = LoadResourceFile(bridgeResName, 'config/config.lua')
    local configFn = configContent and load(configContent, '@@config/config.lua')
    config = (configFn and configFn()) or config

    local detectContent = LoadResourceFile(bridgeResName, 'detection.lua')
    local detectFn = detectContent and load(detectContent, '@@detection.lua')
    if detectFn then
        config = detectFn()(config) or config
    end

    return config
end
