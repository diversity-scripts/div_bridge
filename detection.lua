-------------------------------------------------------------------------------
-- Auto Detection Logic
-------------------------------------------------------------------------------

local function getFramework()
    if GetResourceState('es_extended') == 'started' then return 'esx' end
    if GetResourceState('qbx_core') == 'started' then return 'qbx' end
    if GetResourceState('qb-core') == 'started' then return 'qb' end
    if GetResourceState('ox_core') == 'started' then return 'ox_core' end
    if GetResourceState('ND_Core') == 'started' then return 'nd_core' end
    if GetResourceState('core') == 'started' then return 'tmc' end
    return 'custom'
end

local function getInventory()
    if GetResourceState('ox_inventory') == 'started' then return 'ox_inventory' end
    if GetResourceState('qb-inventory') == 'started' then return 'qb-inventory' end
    if GetResourceState('qs-inventory') == 'started' then return 'qs-inventory' end
    if GetResourceState('origen-inventory') == 'started' then return 'origen-inventory' end
    if GetResourceState('tgiann-inventory') == 'started' then return 'tgiann-inventory' end
    if GetResourceState('minventory') == 'started' then return 'codem-inventory' end
    if GetResourceState('core_inventory') == 'started' then return 'core_inventory' end
    if GetResourceState('ps-inventory') == 'started' then return 'ps-inventory' end
    if GetResourceState('ak47_inventory') == 'started' then return 'ak47_inventory' end
    if GetResourceState('inventory') == 'started' then return 'chezza_inventory' end
    return 'custom'
end

local function getDatabase()
    if GetResourceState('oxmysql') == 'started' then return 'oxmysql' end
    if GetResourceState('mysql-async') == 'started' then return 'mysql-async' end
    if GetResourceState('ghmattimysql') == 'started' and GetResourceState('oxmysql') == 'missing' then return 'ghmattimysql' end
    return 'custom'
end

local function getInteraction()
    if GetResourceState('ox_target') == 'started' then return 'ox_target' end
    if GetResourceState('qb-target') == 'started' then return 'qb-target' end
    if GetResourceState('core_focus') == 'started' then return 'core_focus' end
    return 'custom'
end

return function(Config)
    if Config.Framework == 'auto' then Config.Framework = getFramework() end
    if Config.Inventory == 'auto' then Config.Inventory = getInventory() end
    if Config.Database == 'auto' then Config.Database = getDatabase() end
    if Config.Interaction == 'auto' then Config.Interaction = getInteraction() end
    return Config
end
