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
    return 'none'
end

local function getInventory(framework)
    if GetResourceState('ox_inventory') == 'started' then return 'ox_inventory' end
    if GetResourceState('qb-inventory') == 'started' then return 'qb-inventory' end
    if GetResourceState('qs-inventory') == 'started' then return 'qs-inventory' end
    if GetResourceState('origen-inventory') == 'started' then return 'origen-inventory' end
    if GetResourceState('tgiann-inventory') == 'started' then return 'tgiann-inventory' end
    if GetResourceState('minventory') == 'started' then return 'codem-inventory' end
    if GetResourceState('core_inventory') == 'started' then return 'core_inventory' end
    if GetResourceState('ps-inventory') == 'started' then return 'ps-inventory' end
    if GetResourceState('ak47_inventory') == 'started' then return 'ak47_inventory' end
    if GetResourceState('jaksam_inventory') == 'started' then return 'jaksam_inventory' end
    if framework ~= 'none' and framework ~= 'custom' then return 'framework' end
    return 'none'
end

local function getDatabase()
    if GetResourceState('oxmysql') == 'started' then return 'oxmysql' end
    if GetResourceState('mysql-async') == 'started' then return 'mysql-async' end
    if GetResourceState('ghmattimysql') == 'started' and GetResourceState('oxmysql') == 'missing' then return 'ghmattimysql' end
    return 'none'
end

local function getInteraction()
    if GetResourceState('ox_target') == 'started' then return 'ox_target' end
    if GetResourceState('qb-target') == 'started' then return 'qb-target' end
    if GetResourceState('core_focus') == 'started' then return 'core_focus' end
    return 'none'
end

local function getNotification(framework)
    if GetResourceState('ox_lib') == 'started' then return 'ox_lib' end
    if GetResourceState('okokNotify') == 'started' then return 'okokNotify' end
    if GetResourceState('mythic_notify') == 'started' then return 'mythic_notify' end
    if GetResourceState('pNotify') == 'started' then return 'pNotify' end
    if GetResourceState('17mov_Hud') == 'started' then return '17mov_Hud' end
    if GetResourceState('codem-notification') == 'started' then return 'codem-notification' end
    if framework ~= 'none' and framework ~= 'custom' then return 'framework' end
    return 'standalone'
end

local function getTextUI(framework)
    if GetResourceState('ox_lib') == 'started' then return 'ox_lib' end
    if GetResourceState('jg-textui') == 'started' then return 'jg-textui' end
    if GetResourceState('okokTextUI') == 'started' then return 'okokTextUI' end
    if GetResourceState('cd_drawtextui') == 'started' then return 'cd_drawtextui' end
    if GetResourceState('codem-textui') == 'started' then return 'codem-textui' end
    if GetResourceState('brutal_textui') == 'started' then return 'brutal_textui' end
    if framework ~= 'none' and framework ~= 'custom' then return 'framework' end
    return 'standalone'
end

local function getBank(framework)
    if GetResourceState('ox_banking') == 'started' then return 'ox_banking' end
    if GetResourceState('qb-banking') == 'started' then return 'qb-banking' end
    if GetResourceState('wasabi_banking') == 'started' then return 'wasabi_banking' end
    if GetResourceState('okokBanking') == 'started' then return 'okokBanking' end
    if GetResourceState('tgiann-bank') == 'started' then return 'tgiann-bank' end
    if GetResourceState('kartik-banking') == 'started' then return 'kartik-banking' end
    if GetResourceState('fd_banking') == 'started' then return 'fd_banking' end
    if GetResourceState('renewed-banking') == 'started' then return 'renewed-banking' end
    if framework ~= 'none' and framework ~= 'custom' then return 'framework' end
    return 'none'
end

return function(Config)
    if Config.Framework == 'auto' then Config.Framework = getFramework() end
    if Config.Inventory == 'auto' then Config.Inventory = getInventory(Config.Framework) end
    if Config.Database == 'auto' then Config.Database = getDatabase() end
    if Config.Interaction == 'auto' then Config.Interaction = getInteraction() end
    if Config.Notification == 'auto' then Config.Notification = getNotification(Config.Framework) end
    if Config.TextUI == 'auto' then Config.TextUI = getTextUI(Config.Framework) end
    if Config.Banking == 'auto' then Config.Banking = getBank(Config.Framework) end
    return Config
end
