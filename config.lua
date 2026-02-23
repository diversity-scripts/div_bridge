local Config = {}

-- FRAMEWORK
------------------------
-- Options:
-- 'auto'
-- 'esx'
-- 'qb'
-- 'qbx'
-- 'ox_core'
-- 'nd_core'
-- 'tmc'
-- 'custom'
Config.Framework = 'auto'

-- INVENTORY
------------------------
-- Options:
-- 'auto'
-- 'ox_inventory'
-- 'qs-inventory'
-- 'origen_inventory'
-- 'tgiann_inventory'
-- 'codem-inventory'
-- 'core_inventory'
-- 'ps-inventory'
-- 'ak47_inventory'
-- 'chezza_inventory'
-- 'custom'
Config.Inventory = 'auto'

-- DATABASE
------------------------
-- Options:
-- 'auto'
-- 'oxmysql'
-- 'mysql-async'
-- 'ghmattimysql'
-- 'custom'
Config.Database = 'auto'

-- INTERACTION
------------------------
-- Options:
-- 'auto'
-- 'ox_target'
-- 'qb-target'
-- 'core_focus'
-- 'custom'
Config.Interaction = 'auto'

-- NOTIFICATION
------------------------
-- Options:
-- 'framework'
-- 'ox_lib'
-- 'okokNotify'
-- 'mythic_notify'
-- 'pNotify'
-- '17mov_Hud'
-- 'codem-notification'
-- 'standalone'
-- 'custom'
Config.Notification = 'ox_lib'

-- TEXTUI
------------------------
-- Options:
-- 'ox_lib'
-- 'esx'
-- 'qb'
-- 'jg-textui'
-- 'okokTextUI'
-- 'cd_drawtextui'
-- 'codem-textui'
-- 'brutal_textui'
-- 'standalone'
-- 'custom'
Config.TextUI = 'ox_lib'

return Config
