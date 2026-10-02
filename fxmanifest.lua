fx_version 'cerulean'
game 'gta5'

author 'Diversity'
description 'Bridge resource for scripts'
version '1.1.0'

client_script 'client.lua'
server_script 'server.lua'

ui_page 'web/build/index.html'

files {
    'config/config.lua',
    'config/config_ui.lua',
    'detection.lua',
    'init.lua',
    'modules/**/*.lua',
    'lib/init.lua',
    'lib/**/*.lua',
    'web/build/**'
}

exports {
    'GetProvider',
    'Notify', 'NotifyUpdate', 'NotifyClose',
    'RegisterContext', 'ShowContext', 'HideContext', 'UpdateContext', 'GetOpenContextMenu',
    'ShowTextUI', 'HideTextUI', 'UpdateTextUI',
    'Progress',
    'InputDialog', 'AlertDialog', 'ConfirmDialog',
    'SkillCheck', 'Minigame',
    'TaskStart', 'TaskUpdate', 'TaskProgress', 'TaskFinish', 'TaskCancel',
    'SetKeybinds',
    'ShowSubtitle', 'HideSubtitle',
    'ShowFloatingLabel', 'UpdateFloatingLabel', 'HideFloatingLabel',
}

-- Server-side only exposes the notification family; all other UI components are
-- client-only. These back the dBridge.UI proxy when called from a server script.
server_exports {
    'GetProvider',
    'Notify', 'ToPlayer', 'ToAllPlayers', 'ToJob', 'ToACEPermission',
}
