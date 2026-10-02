local Config = {}

-- Mode for debugging
Config.Debug = false

-- Language for the locale files
-- Change this to your preferred language (must match the locale file name eg.: 'en', 'fr', etc)
Config.Language = 'en'

-- FRAMEWORK
-- Change to 'none' to disable the module
------------------------
-- none | auto | standalone | esx | qb | qbx | ox_core | nd_core | tmc | custom
Config.Framework = 'auto'

-- INVENTORY
-- Change to 'none' to disable the module
------------------------
-- none | auto | framework | ox_inventory | qb-inventory | qs-inventory | origen_inventory | tgiann-inventory | codem-inventory | core_inventory | ps-inventory | ak47_inventory | jaksam_inventory | custom
Config.Inventory = 'auto'

-- DATABASE
-- Change to 'none' to disable the module
------------------------
-- none | auto | oxmysql | mysql-async | ghmattimysql | custom
Config.Database = 'auto'

-- INTERACTION
-- Change to 'none' to disable the module
------------------------
-- none | auto | ox_target | qb-target | core_focus | custom
Config.Interaction = 'auto'

-- BANKING
-- Change to 'none' to disable the module
------------------------
-- none | auto | framework | qb-banking | okokBanking | tgiann-bank | kartik-banking | fd_banking | renewed-banking | custom
Config.Banking = 'auto'

-- UI
-- Unified UI module with per-component provider selection.
-- Each component can be set to a specific provider or 'internal' (built-in NUI).
-- 'auto' will detect the best available provider, falling back to 'internal'.
-- Components without a matching adapter for the chosen provider will silently fall back to 'internal'.
------------------------
Config.UI = {
    -- none | auto | internal | framework | ox_lib | okokNotify | mythic_notify | pNotify | 17mov_Hud | codem-notification | custom
    Notification = 'internal',
    -- none | auto | internal | framework | ox_lib | jg-textui | okokTextUI | cd_drawtextui | codem-textui | brutal_textui | custom
    TextUI = 'internal',
    -- none | auto | internal | ox_lib | custom
    ProgressBar = 'internal',
    -- none | auto | internal | ox_lib | custom
    SkillCheck = 'internal',
    -- none | auto | internal | ox_lib | custom
    ContextMenu = 'internal',
    -- none | auto | internal | ox_lib | custom
    InputDialog = 'internal',
    -- none | auto | internal | ox_lib | custom
    AlertDialog = 'internal',
    -- internal only (no external adapters exist)
    ConfirmDialog = 'internal',
    -- internal only (no external adapters exist)
    Subtitles = 'internal',
    -- internal only (no external adapters exist)
    FloatingLabels = 'internal',
    -- internal only (no external adapters exist)
    Prompts = 'internal',
    -- internal only (no external adapters exist)
    Keybinds = 'internal',
}

return Config
