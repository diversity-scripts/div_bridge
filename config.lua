local Config = {}

-- Mode for debugging
Config.Debug = false

-- Language for the locale files
-- Change this to your preferred language (must match the locale file name eg.: 'en', 'fr', etc)
Config.Language = 'en'

-- FRAMEWORK
-- Change to 'none' to disable the module
------------------------
-- none | auto | esx | qb | qbx | ox_core | nd_core | tmc | custom
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

-- NOTIFICATION
-- Change to 'none' to disable the module
------------------------
-- none | auto | framework | ox_lib | okokNotify | mythic_notify | pNotify | 17mov_Hud | codem-notification | standalone | custom
Config.Notification = 'auto'

-- TEXTUI
-- Change to 'none' to disable the module
------------------------
-- none | auto | framework | ox_lib | jg-textui | okokTextUI | cd_drawtextui | codem-textui | brutal_textui | standalone | custom
Config.TextUI = 'auto'

-- BANKING
-- Change to 'none' to disable the module
------------------------
-- none | auto | framework | qb-banking | okokBanking | tgiann-bank | kartik-banking | fd_banking | renewed-banking | custom
Config.Banking = 'auto'

return Config
