-------------------------------------------------------------------------------
-- Internal UI Implementation (Client)
-- The built-in NUI-powered UI system. This is the full implementation that
-- was previously in lib/ui/client.lua, now living inside the bridge module.
-------------------------------------------------------------------------------

local UI = {}

local bridgeResName = 'div_bridge'
local LoadResourceFile = LoadResourceFile

local configContent = LoadResourceFile(bridgeResName, 'config/config_ui.lua')
local Config = load(configContent, '@@div_bridge/config/config_ui.lua')()

local keymapContent = LoadResourceFile(bridgeResName, 'modules/ui/internal/shared.lua')
local KeyMap = load(keymapContent, '@@div_bridge/modules/ui/internal/shared.lua')()

local notificationIdCounter = 0
local activeNotificationCallbacks = {}
-- Tracks notification ids that are currently showing, so a repeat Notify with the
-- same caller-supplied id updates the existing toast instead of stacking a new one.
-- The value is a monotonically increasing "generation" so a stale auto-expire timer
-- won't clear a notification that was refreshed after the timer was scheduled.
local activeNotificationIds = {}
local notificationGeneration = 0

-- Normalises common type aliases to the canonical set used by Config/NUI.
local NOTIFY_TYPE_ALIASES = {
    inform = 'info',
    information = 'info',
    err = 'error',
    warn = 'warning',
    ok = 'success',
}

local function normalizeNotifyType(t)
    if type(t) ~= 'string' then return t end
    return NOTIFY_TYPE_ALIASES[t] or t
end
local isActionableNotificationVisible = false
local isMouseToggled = false
local activeKeybinds = {}
local isMinigameActive = false
local minigameCallback = nil
local minigameTimeoutTimer = nil
local registeredContexts = {}
local activeContextId = nil
local dialogPromises = {}
local activeFloatingLabels = {}

-- On-demand background threads: each runs only while it has work and exits when
-- idle, so the resource sits at ~0.00ms when nothing is happening. The *Running
-- flags prevent spawning duplicate threads.
local focusThreadRunning = false
local keybindThreadRunning = false
local labelThreadRunning = false
local ensureFocusThread, ensureKeybindThread, ensureLabelThread

local MinigameRegistry = {
    skillcheck = {
        focus = 'keyboard',
        presets = Config.Minigames.skillcheck,
        requiredFields = { 'speed', 'areaSize' },
    },
    rapidkeys = {
        focus = 'keyboard',
        presets = Config.Minigames.rapidkeys,
        requiredFields = { 'duration' },
    },
    memory = {
        focus = 'mouse',
        presets = Config.Minigames.memory,
        requiredFields = { 'gridSize', 'patternLength', 'previewDuration' },
    },
    timingbar = {
        focus = 'keyboard',
        presets = Config.Minigames.timingbar,
        requiredFields = { 'rounds', 'speed', 'zoneSize' },
    },
    wireconnect = {
        focus = 'mouse',
        presets = Config.Minigames.wireconnect,
        requiredFields = { 'gridSize', 'pairs', 'timeLimit' },
    },
    numberpad = {
        focus = 'mouse',
        presets = Config.Minigames.numberpad,
        requiredFields = { 'code', 'attempts', 'timeLimit' },
    },
    lockpick = {
        focus = 'keyboard',
        presets = Config.Minigames.lockpick,
        requiredFields = { 'picks', 'sweetSpotSize', 'timeLimit' },
    },
    circuitbreaker = {
        focus = 'mouse',
        presets = Config.Minigames.circuitbreaker,
        requiredFields = { 'switchCount', 'linkedPairs', 'timeLimit' },
    },
}

local function toggleMouse(state)
    isMouseToggled = state
    SetNuiFocus(state, state)
    SendNUIMessage({ action = 'updateFocusState', state = isMouseToggled })
    if state then ensureFocusThread() end
end

local function onNotificationHandled(notificationId)
    activeNotificationIds[notificationId] = nil
    if activeNotificationCallbacks[notificationId] then
        activeNotificationCallbacks[notificationId] = nil
        isActionableNotificationVisible = false
        for _, _ in pairs(activeNotificationCallbacks) do
            isActionableNotificationVisible = true
            break
        end
        if not isActionableNotificationVisible and isMouseToggled then
            toggleMouse(false)
        end
    end
end

---@param data {id: number, type?: string, title?: string, text: string, duration?: number, actions?: table}
---@return number notificationId
UI.Notify = function(data)
    data.type = normalizeNotifyType(data.type)

    -- If the caller supplied an id, reuse it so repeated calls update one toast
    -- instead of spamming new ones. Otherwise auto-generate a unique numeric id.
    local notificationId
    local isUpdate = false
    if data.id ~= nil then
        notificationId = data.id
        isUpdate = activeNotificationIds[notificationId] ~= nil
    else
        notificationIdCounter = notificationIdCounter + 1
        notificationId = notificationIdCounter
        data.id = notificationId
    end

    if data.actions then
        isActionableNotificationVisible = true
        activeNotificationCallbacks[notificationId] = {}
        local actionsForNui = {}
        for id, actionData in pairs(data.actions) do
            activeNotificationCallbacks[notificationId][id] = actionData.callback
            actionsForNui[id] = { label = actionData.label }
        end
        data.actions = actionsForNui
        SendNUIMessage({ action = 'updateFocusState', state = isMouseToggled })
        ensureFocusThread()
    end

    notificationGeneration = notificationGeneration + 1
    local generation = notificationGeneration
    activeNotificationIds[notificationId] = generation

    if isUpdate then
        -- Refresh the existing toast in place (resets its timer/content on the NUI).
        SendNUIMessage({ action = 'update', id = notificationId, data = data })
    else
        SendNUIMessage({ action = 'show', data = data })
    end

    -- Non-actionable toasts auto-dismiss on the NUI after their duration. Mirror
    -- that here with a timer so the "currently showing" flag self-expires even if
    -- the NUI doesn't report a timeout. Actionable toasts stay tracked until handled.
    if not data.actions then
        local lifetime = (data.duration or Config.DefaultDuration or 5000) + 500
        local trackedId = notificationId
        SetTimeout(lifetime, function()
            -- Only clear if this generation is still the active one (i.e. the toast
            -- wasn't refreshed by a later Notify after this timer was scheduled).
            if activeNotificationIds[trackedId] == generation then
                activeNotificationIds[trackedId] = nil
            end
        end)
    end

    return notificationId
end

---@param id number
---@param data {type?: string, title?: string, text?: string, duration?: number}
UI.NotifyUpdate = function(id, data)
    SendNUIMessage({ action = 'update', id = id, data = data })
end

---@param id number
UI.NotifyClose = function(id)
    SendNUIMessage({ action = 'dismiss', id = id })
    activeNotificationIds[id] = nil
    if activeNotificationCallbacks[id] then
        onNotificationHandled(id)
    end
end

---@param id string
---@param data {title: string, text?: string, icon?: string}
UI.TaskStart = function(id, data)
    SendNUIMessage({ action = 'startTask', id = id, data = data })
end

---@param id string
---@param data {title?: string, text?: string, progress?: number, duration?: number}
UI.TaskUpdate = function(id, data)
    SendNUIMessage({ action = 'updateTask', id = id, data = data })
end

---@param id string
---@param data {progress: number, text?: string, duration: number}
---@return promise
UI.TaskProgress = function(id, data)
    local p = promise.new()
    SendNUIMessage({ action = 'updateTask', id = id, data = data })
    if data and data.duration and data.duration > 0 then
        SetTimeout(data.duration, function()
            p:resolve(true)
        end)
    else
        p:resolve(true)
    end
    return p
end

---@param id string
---@param data {state: 'success'|'error', text?: string}
UI.TaskFinish = function(id, data)
    SendNUIMessage({ action = 'finishTask', id = id, data = data })
end

---@param id string
UI.TaskCancel = function(id)
    SendNUIMessage({ action = 'cancelTask', id = id })
end

---@param id string
---@param data {text: string, icon?: string, position?: string}
UI.ShowTextUI = function(id, data)
    SendNUIMessage({ action = 'showPrompt', id = id, data = data })
end

---@param id string
UI.HideTextUI = function(id)
    SendNUIMessage({ action = 'hidePrompt', id = id })
end

---@param keybinds {key: string, action: string}[]
UI.SetKeybinds = function(keybinds)
    activeKeybinds = keybinds or {}
    SendNUIMessage({ action = 'setKeybinds', data = activeKeybinds })
    if #activeKeybinds > 0 then ensureKeybindThread() end
end

---@param difficulty string|{speed: number, areaSize: number}
---@param key? string
---@param callback fun(success: boolean)
UI.SkillCheck = function(difficulty, key, callback)
    local config
    if type(difficulty) == 'string' then
        -- Resolve the preset and add the key
        local preset = Config.SkillCheck.difficulties[difficulty]
        if preset then
            config = {
                speed = preset.speed,
                areaSize = preset.areaSize,
                key = key or Config.SkillCheck.defaultKey,
            }
        else
            -- Pass the string to UI.Minigame; it will handle the error
            config = difficulty
        end
    else
        -- Direct config table: add the key
        config = {
            speed = difficulty.speed,
            areaSize = difficulty.areaSize,
            key = key or Config.SkillCheck.defaultKey,
        }
    end

    -- Delegate to the unified API
    UI.Minigame('skillcheck', config, callback)
end

---@param minigameType string Minigame type identifier
---@param config string|table Preset name or difficulty config table
---@param callback fun(success: boolean)
UI.Minigame = function(minigameType, config, callback)
    -- Mutex guard: only one minigame at a time
    if isMinigameActive then return end

    -- Validate type exists in registry
    local registry = MinigameRegistry[minigameType]
    if not registry then
        print('^1[div_bridge - UI] Invalid minigame type: ' .. tostring(minigameType) .. '^0')
        if callback then callback(false) end
        return
    end

    -- Resolve config: string → preset lookup, table → direct use
    local resolvedConfig
    if type(config) == 'string' then
        if registry.presets and registry.presets[config] then
            -- Deep copy the preset so we don't mutate the original
            resolvedConfig = {}
            for k, v in pairs(registry.presets[config]) do
                resolvedConfig[k] = v
            end
        else
            print('^1[div_bridge - UI] Invalid preset "' .. config .. '" for minigame type "' .. minigameType .. '". Available: easy, medium, hard^0')
            if callback then callback(false) end
            return
        end
    elseif type(config) == 'table' then
        resolvedConfig = config
    else
        print('^1[div_bridge - UI] Config must be a string (preset name) or table, got: ' .. type(config) .. '^0')
        if callback then callback(false) end
        return
    end

    -- Validate required fields
    for _, field in ipairs(registry.requiredFields) do
        -- For numberpad, 'code' can be nil (will be generated)
        if field == 'code' and minigameType == 'numberpad' then
            -- Skip code validation for numberpad; it will be generated below if nil
        elseif resolvedConfig[field] == nil then
            print('^3[div_bridge - UI] Missing required field "' .. field .. '" for minigame type "' .. minigameType .. '"^0')
            if callback then callback(false) end
            return
        end
    end

    -- For numberpad: generate random code if code is nil
    if minigameType == 'numberpad' and resolvedConfig.code == nil then
        local codeLength = resolvedConfig.codeLength or 4
        local code = ''
        for i = 1, codeLength do
            code = code .. tostring(math.random(0, 9))
        end
        resolvedConfig.code = code
    end

    -- For rapidkeys: generate random keys if keys is nil but keyCount is provided
    if minigameType == 'rapidkeys' and resolvedConfig.keys == nil then
        local keyCount = resolvedConfig.keyCount or 5
        local pool = resolvedConfig.keyPool or {"W", "A", "S", "D", "E", "Q", "R", "F", "G", "H", "X", "C", "V"}
        local keys = {}
        for i = 1, keyCount do
            keys[i] = pool[math.random(1, #pool)]
        end
        resolvedConfig.keys = keys
    end

    -- Set active state and store callback
    isMinigameActive = true
    minigameCallback = callback

    -- Determine focus mode and set NUI focus
    if registry.focus == 'mouse' then
        SetNuiFocus(true, true)
    else
        SetNuiFocus(true, false)
    end

    -- Send NUI message with resolved config
    notificationIdCounter = notificationIdCounter + 1
    SendNUIMessage({
        action = 'showMinigame',
        data = {
            id = 'minigame_' .. notificationIdCounter,
            type = minigameType,
            config = resolvedConfig,
            cancelKey = resolvedConfig.cancelKey or 'Backspace',
            stages = resolvedConfig.stages or 1,
            stageConfigs = resolvedConfig.stageConfigs or nil,
            escalate = resolvedConfig.escalate or false,
        }
    })

    -- Play start sound
    PlaySoundFrontend(-1, "SELECT", "HUD_MINI_GAME_SOUNDSET", true)

    -- Start 60-second safety timeout
    minigameTimeoutTimer = SetTimeout(60000, function()
        if isMinigameActive then
            -- Timeout reached with no result — force cleanup
            SetNuiFocus(false, false)
            SendNUIMessage({ action = 'hideMinigame' })

            isMinigameActive = false
            local cb = minigameCallback
            minigameCallback = nil
            minigameTimeoutTimer = nil

            if cb then cb(false) end
        end
    end)
end

---@param data {id: string, title: string, menu?: string, position?: string, canClose?: boolean, onExit?: function, options: table[]}
UI.RegisterContext = function(data)
    if type(data) ~= 'table' or not data.id then
        print('^1[div_bridge - UI] RegisterContext failed: missing id or invalid data.^0')
        return
    end
    registeredContexts[data.id] = data
    dBridge.debugPrint('[div_bridge - UI] RegisterContext: "' .. data.id .. '" registered with ' .. #(data.options or {}) .. ' options.')
end

---@param id string
UI.ShowContext = function(id)
    local context = registeredContexts[id]
    if not context then
        print('^1[div_bridge - UI] ShowContext failed: "' .. tostring(id) .. '" is not registered. Registered menus: ' .. (next(registeredContexts) and table.concat((function() local t = {} for k in pairs(registeredContexts) do t[#t+1] = k end return t end)(), ', ') or 'none') .. '^0')
        return
    end

    dBridge.debugPrint('[div_bridge - UI] ShowContext: showing "' .. id .. '"')
    activeContextId = id

    local nuiData = {
        id = context.id,
        title = context.title,
        description = context.description,
        menu = context.menu,
        canClose = context.canClose,
        searchable = context.searchable,
        position = context.position or 'top-right',
        options = {}
    }

    for _, option in ipairs(context.options) do
        local opt = {
            title = option.title,
            description = option.description,
            icon = option.icon,
            iconColor = option.iconColor,
            iconAnimation = option.iconAnimation,
            progress = option.progress,
            colorScheme = option.colorScheme,
            arrow = option.arrow,
            disabled = option.disabled,
            readOnly = option.readOnly,
            close = option.close,
            image = option.image,
            metadata = option.metadata,
            menu = option.menu,
            event = option.event,
            serverEvent = option.serverEvent,
            args = option.args
        }

        if opt.menu and opt.arrow == nil then opt.arrow = true end
        table.insert(nuiData.options, opt)
    end

    SetNuiFocus(true, true)
    dBridge.debugPrint('[div_bridge - UI] ShowContext: sending NUI message for "' .. id .. '" with ' .. #nuiData.options .. ' options.')
    SendNUIMessage({ action = 'showContext', data = nuiData })
end

UI.HideContext = function()
    local id = activeContextId
    if not id then return end

    local context = registeredContexts[id]
    if context and context.onExit then
        context.onExit()
    end

    activeContextId = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hideContext' })
end

---@return string|nil The ID of the currently open context menu, or nil if none is open
UI.GetOpenContextMenu = function()
    return activeContextId
end

---@param id string The ID of the context menu to update
---@param data table Updated context menu data (same format as RegisterContext)
UI.UpdateContext = function(id, data)
    if type(data) ~= 'table' then return end
    data.id = id
    registeredContexts[id] = data

    -- If this menu is currently open, refresh it live
    if activeContextId == id then
        UI.ShowContext(id)
    end
end

---@param data {type?: string, title?: string, text: string, duration?: number, actions?: table}
---@param id? number Existing notification ID to update, or nil to create new
---@return number notificationId
UI.NotifyUpdate = function(id, data)
    SendNUIMessage({ action = 'update', id = id, data = data })
end

---@param id string
---@param data {text: string, icon?: string, position?: string}|string
UI.UpdateTextUI = function(id, data)
    SendNUIMessage({ action = 'showPrompt', id = id, data = type(data) == 'string' and { text = data } or data })
end

---@param id string
---@param data table Updated progress data
UI.UpdateProgress = function(data)
    SendNUIMessage({ action = 'progress', data = data })
end

---@param data {type?: 'bar'|'circle', duration: number, label?: string, subtitle?: string, icon?: string, colorScheme?: string, stages?: number, activeStage?: number, cancelKey?: string, position?: string}
---@return boolean completed
UI.Progress = function(data)
    if not data then return false end

    local cancelControl = nil
    if data.cancelKey then
        cancelControl = KeyMap.KeyToControl[data.cancelKey:upper()]
    end

    SendNUIMessage({
        action = 'progress',
        data = {
            type = data.type or 'bar',
            duration = data.duration or 3000,
            label = data.label,
            subtitle = data.subtitle,
            icon = data.icon,
            colorScheme = data.colorScheme,
            stages = data.stages,
            activeStage = data.activeStage,
            cancelKey = data.cancelKey,
            position = data.position or 'bottom'
        }
    })

    local duration = data.duration or 3000
    local endTime = GetGameTimer() + duration

    while GetGameTimer() < endTime do
        if cancelControl then
            DisableControlAction(0, cancelControl, true)
            if IsDisabledControlJustPressed(0, cancelControl) then
                SendNUIMessage({ action = 'cancelProgress' })
                return false
            end
        end
        Wait(0)
    end

    return true
end

---@param heading string
---@param rows table[]
---@param options? {allowCancel?: boolean, layout?: 'vertical'|'grid'}
---@return table|nil values
UI.InputDialog = function(heading, rows, options)
    local p = promise.new()
    local dialogId = 'input_' .. GetGameTimer() .. '_' .. math.random(1000, 9999)

    options = options or {}

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'inputDialog',
        data = {
            id = dialogId,
            heading = heading or '',
            rows = rows,
            options = options
        }
    })

    dialogPromises[dialogId] = p
    return Citizen.Await(p)
end

---@param heading string
---@param message string
---@param buttons? string[]
---@return boolean confirmed
UI.AlertDialog = function(heading, message, buttons)
    local p = promise.new()
    local dialogId = 'alert_' .. GetGameTimer() .. '_' .. math.random(1000, 9999)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'alertDialog',
        data = {
            id = dialogId,
            heading = heading or '',
            message = message or '',
            buttons = buttons or { 'OK' }
        }
    })

    dialogPromises[dialogId] = p
    return Citizen.Await(p)
end

---@param data {heading: string, message: string, confirmWord?: string, confirmText?: string, cancelText?: string, placeholder?: string, icon?: string, type?: 'default'|'danger'}
---@return {confirmed: boolean, value: string|nil}
UI.ConfirmDialog = function(data)
    local p = promise.new()
    local dialogId = 'confirm_' .. GetGameTimer() .. '_' .. math.random(1000, 9999)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'confirmDialog',
        data = {
            id = dialogId,
            heading = data.heading or 'Confirm',
            message = data.message or '',
            confirmWord = data.confirmWord,
            confirmText = data.confirmText,
            cancelText = data.cancelText,
            placeholder = data.placeholder,
            icon = data.icon,
            type = data.type or 'default'
        }
    })

    dialogPromises[dialogId] = p
    return Citizen.Await(p)
end

---@param id string
---@param data {text: string, subText?: string, icon?: string, color?: string, key?: string, x?: number, y?: number, coords?: vector3, entity?: number, offset?: vector3, distance?: number, position?: string, screenOffset?: {x: number, y: number}}
UI.ShowFloatingLabel = function(id, data)
    if not activeFloatingLabels then activeFloatingLabels = {} end
    activeFloatingLabels[id] = {
        id = id,
        text = data.text,
        subText = data.subText,
        icon = data.icon,
        color = data.color,
        key = data.key,
        coords = data.coords,
        entity = data.entity,
        offset = data.offset or vec3(0.0, 0.0, 0.8),
        distance = data.distance or 10.0,
        position = data.position or 'center',
        screenOffset = data.screenOffset or { x = 0, y = 0 },
        static = data.x ~= nil,
        visible = false
    }
    if data.x then
        SendNUIMessage({ action = 'showFloatingLabel', id = id, data = {
            text = data.text,
            subText = data.subText,
            icon = data.icon,
            color = data.color,
            key = data.key,
            position = data.position,
            x = data.x + (data.screenOffset and data.screenOffset.x or 0),
            y = data.y + (data.screenOffset and data.screenOffset.y or 0)
        }})
    else
        -- World/entity-attached label needs the projection loop.
        ensureLabelThread()
    end
end

---@param id string
---@param data table
UI.UpdateFloatingLabel = function(id, data)
    if activeFloatingLabels and activeFloatingLabels[id] then
        for k, v in pairs(data) do
            activeFloatingLabels[id][k] = v
        end
    end
    SendNUIMessage({ action = 'updateFloatingLabel', id = id, data = data })
end

---@param id string
UI.HideFloatingLabel = function(id)
    if activeFloatingLabels then activeFloatingLabels[id] = nil end
    SendNUIMessage({ action = 'hideFloatingLabel', id = id })
end

---@param data {text: string, speaker?: string, speakerColor?: string, typeSpeed?: number, duration?: number, position?: 'top'|'bottom', background?: boolean}
UI.ShowSubtitle = function(data)
    SendNUIMessage({
        action = 'showSubtitle',
        data = {
            text = data.text or '',
            speaker = data.speaker,
            speakerColor = data.speakerColor,
            typeSpeed = data.typeSpeed or Config.Subtitles.typeSpeed,
            duration = data.duration or Config.Subtitles.defaultDuration,
            position = data.position or Config.Subtitles.position,
            background = data.background or false
        }
    })
end

UI.HideSubtitle = function()
    SendNUIMessage({ action = 'hideSubtitle' })
end

-------------------------------------------------------------------------------
-- NUI Callbacks
-------------------------------------------------------------------------------

RegisterNUICallback('onAction', function(data, cb)
    local notificationId = data.notificationId
    local actionId = data.actionId

    if activeNotificationCallbacks[notificationId] and activeNotificationCallbacks[notificationId][actionId] then
        activeNotificationCallbacks[notificationId][actionId]()
    end

    SendNUIMessage({ action = 'dismiss', id = notificationId })
    onNotificationHandled(notificationId)
    toggleMouse(false)
    cb(1)
end)

RegisterNUICallback('onTimeout', function(data, cb)
    onNotificationHandled(data.notificationId)
    cb(1)
end)

RegisterNUICallback('toggleFocus', function(_, cb)
    if isMouseToggled then
        toggleMouse(false)
    end
    cb(1)
end)

RegisterNUICallback('skillCheckResult', function(data, cb)
    SetNuiFocus(false, false)

    -- Clear safety timeout
    if minigameTimeoutTimer then
        ClearTimeout(minigameTimeoutTimer)
        minigameTimeoutTimer = nil
    end

    if data.success then
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_MINI_GAME_SOUNDSET", true)
    else
        PlaySoundFrontend(-1, "Click_Fail", "WEB_NAVIGATION_SOUNDS_PHONE", true)
    end

    local callback = minigameCallback
    minigameCallback = nil
    isMinigameActive = false

    if callback then
        callback(data.success)
    end
    cb(1)
end)

RegisterNUICallback('minigameResult', function(data, cb)
    -- Release NUI focus
    SetNuiFocus(false, false)

    -- Clear safety timeout
    if minigameTimeoutTimer then
        ClearTimeout(minigameTimeoutTimer)
        minigameTimeoutTimer = nil
    end

    -- Play appropriate sound
    if data.success then
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_MINI_GAME_SOUNDSET", true)
    else
        PlaySoundFrontend(-1, "Click_Fail", "WEB_NAVIGATION_SOUNDS_PHONE", true)
    end

    -- Store callback reference and reset state
    local callback = minigameCallback
    minigameCallback = nil

    -- Small cooldown before allowing next minigame (lets React unmount cleanly)
    SetTimeout(300, function()
        isMinigameActive = false
        if callback then
            callback(data.success)
        end
    end)

    cb(1)
end)

RegisterNUICallback('playSound', function(data, cb)
    if data.sound == 'start' then
        PlaySoundFrontend(-1, "SELECT", "HUD_MINI_GAME_SOUNDSET", true)
    elseif data.sound == 'success' then
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_MINI_GAME_SOUNDSET", true)
    elseif data.sound == 'failure' then
        PlaySoundFrontend(-1, "Click_Fail", "WEB_NAVIGATION_SOUNDS_PHONE", true)
    end
    cb(1)
end)

RegisterNUICallback('closeContext', function(_, cb)
    local id = activeContextId
    if not id then
        cb(1)
        return
    end

    local context = registeredContexts[id]
    if context and context.onExit then
        context.onExit()
    end
    if context and context._sourceResource then
        TriggerEvent('div_bridge:ui:contextExit', id)
    end

    activeContextId = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hideContext' })
    cb(1)
end)

RegisterNUICallback('backContext', function(data, cb)
    local currentId = data.menuId
    local parentId = data.parentId

    local currentCtx = registeredContexts[currentId]
    if currentCtx and currentCtx.onBack then
        currentCtx.onBack()
    end
    if currentCtx and currentCtx._sourceResource then
        TriggerEvent('div_bridge:ui:contextBack', currentId)
    end

    if parentId then
        UI.ShowContext(parentId)
    else
        activeContextId = nil
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'hideContext' })
    end
    cb(1)
end)

RegisterNUICallback('clickContext', function(data, cb)
    local menuId = data.menuId
    local index = data.index
    local context = registeredContexts[menuId]

    if context and context.options and context.options[index] then
        local option = context.options[index]

        if option.onSelect then
            option.onSelect(option.args)
        end

        -- Fire callback event back to the resource that registered this menu
        if context._sourceResource then
            TriggerEvent('div_bridge:ui:contextClick', menuId, index, option.args)
        end

        if option.event then
            TriggerEvent(option.event, option.args)
        end

        if option.serverEvent then
            TriggerServerEvent(option.serverEvent, option.args)
        end

        if option.menu then
            UI.ShowContext(option.menu)
        elseif option.close then
            activeContextId = nil
            SetNuiFocus(false, false)
            SendNUIMessage({ action = 'hideContext' })
        end
    end
    cb(1)
end)

RegisterNUICallback('inputDialogSubmit', function(data, cb)
    local dialogId = data.id
    if dialogPromises[dialogId] then
        dialogPromises[dialogId]:resolve(data.values)
        dialogPromises[dialogId] = nil
        SetNuiFocus(false, false)
    end
    cb(1)
end)

RegisterNUICallback('inputDialogCancel', function(data, cb)
    local dialogId = data.id
    if dialogPromises[dialogId] then
        dialogPromises[dialogId]:resolve(nil)
        dialogPromises[dialogId] = nil
        SetNuiFocus(false, false)
    end
    cb(1)
end)

RegisterNUICallback('alertDialogResult', function(data, cb)
    local dialogId = data.id
    if dialogPromises[dialogId] then
        dialogPromises[dialogId]:resolve(data.confirmed)
        dialogPromises[dialogId] = nil
        SetNuiFocus(false, false)
    end
    cb(1)
end)

RegisterNUICallback('confirmDialogResult', function(data, cb)
    local dialogId = data.id
    if dialogPromises[dialogId] then
        dialogPromises[dialogId]:resolve({ confirmed = data.confirmed, value = data.value })
        dialogPromises[dialogId] = nil
        SetNuiFocus(false, false)
    end
    cb(1)
end)

-------------------------------------------------------------------------------
-- Background Threads
-------------------------------------------------------------------------------

CreateThread(function()
    Wait(1000)
    local configToSend = {
        Priorities = Config.Priorities,
        Text = Config.Text,
        DefaultDuration = Config.DefaultDuration,
        Colors = Config.Colors,
        InteractKey = Config.InteractKey,
        PromptPositions = Config.PromptPositions
    }
    configToSend.Text.keyDisplay = KeyMap.GetKeyFromControl(Config.InteractKey)
    SendNUIMessage({ action = 'setup', config = configToSend })
end)

-- Notification focus thread: runs only while an actionable notification is
-- visible or the mouse is toggled; exits once neither is true.
ensureFocusThread = function()
    if focusThreadRunning then return end
    focusThreadRunning = true
    CreateThread(function()
        while isActionableNotificationVisible or isMouseToggled do
            Wait(0)
            if isActionableNotificationVisible then
                if not isMouseToggled and IsControlJustReleased(0, Config.InteractKey) then
                    toggleMouse(true)
                elseif isMouseToggled and (IsControlJustReleased(0, Config.InteractKey) or IsControlJustReleased(0, 199)) then
                    toggleMouse(false)
                end
            elseif isMouseToggled then
                toggleMouse(false)
            end
        end
        focusThreadRunning = false
    end)
end

-- Keybind thread: runs only while there are active keybinds; exits when cleared.
ensureKeybindThread = function()
    if keybindThreadRunning then return end
    keybindThreadRunning = true
    CreateThread(function()
        while #activeKeybinds > 0 do
            for _, kb in ipairs(activeKeybinds) do
                local control = KeyMap.KeyToControl[kb.key:upper()]
                if control and IsDisabledControlJustPressed(0, control) then
                    SendNUIMessage({ action = 'keybindPressed', key = kb.key })
                end
            end
            Wait(0)
        end
        keybindThreadRunning = false
    end)
end

RegisterNetEvent('div_bridge:client:ui:notify', function(data)
    UI.Notify(data)
end)

-- Returns true if any tracked floating label needs the projection loop.
local function hasDynamicLabels()
    for _, label in pairs(activeFloatingLabels) do
        if not label.static then return true end
    end
    return false
end

-- Floating-label projection thread: runs only while dynamic labels exist.
ensureLabelThread = function()
    if labelThreadRunning then return end
    labelThreadRunning = true
    CreateThread(function()
    local updateInterval = 50 -- ms between updates
    local fadeStartPercent = 0.7
    local lodNearPercent = 0.5
    local deltaThreshold = 0.002
    local labelLastSent = {}

    while hasDynamicLabels() do
        Wait(updateInterval)

        local playerCoords = GetEntityCoords(PlayerPedId())
        local batch = {}

        for id, label in pairs(activeFloatingLabels) do
            if not label.static then
                local worldCoords
                if label.entity and DoesEntityExist(label.entity) then
                    local entCoords = GetEntityCoords(label.entity)
                    worldCoords = entCoords + (label.offset or vec3(0.0, 0.0, 0.8))
                elseif label.coords then
                    worldCoords = label.coords + (label.offset or vec3(0.0, 0.0, 0.0))
                end

                if worldCoords then
                    local dist = #(playerCoords - worldCoords)
                    local maxDist = label.distance or 10.0

                    if dist <= maxDist then
                        local onScreen, sx, sy = GetScreenCoordFromWorldCoord(worldCoords.x, worldCoords.y, worldCoords.z)
                        if onScreen then
                            local soX = label.screenOffset and label.screenOffset.x or 0
                            local soY = label.screenOffset and label.screenOffset.y or 0
                            local finalX = sx + soX
                            local finalY = sy + soY

                            -- Delta detection
                            local last = labelLastSent[id]
                            local posChanged = not last
                                or math.abs(finalX - last.x) > deltaThreshold
                                or math.abs(finalY - last.y) > deltaThreshold
                            local dataChanged = not last
                                or last.text ~= label.text
                                or last.subText ~= label.subText
                                or last.icon ~= label.icon
                                or last.color ~= label.color
                                or last.key ~= label.key

                            if posChanged or dataChanged then
                                -- Opacity fade
                                local opacity = 1.0
                                local fadeStart = fadeStartPercent * maxDist
                                if dist > fadeStart then
                                    opacity = 1.0 - ((dist - fadeStart) / (maxDist - fadeStart))
                                end
                                if opacity < 0 then opacity = 0 end

                                -- LOD classification (two states: near/far)
                                local lod = 'near'
                                local distRatio = dist / maxDist
                                if distRatio >= lodNearPercent then
                                    lod = 'far'
                                end

                                if not label.visible then
                                    label.visible = true
                                end

                                batch[#batch + 1] = {
                                    id = id,
                                    action = 'show',
                                    x = finalX,
                                    y = finalY,
                                    opacity = opacity,
                                    lod = lod,
                                    text = label.text,
                                    subText = label.subText,
                                    icon = label.icon,
                                    color = label.color,
                                    key = label.key,
                                    position = label.position,
                                }

                                labelLastSent[id] = {
                                    x = finalX, y = finalY,
                                    text = label.text, subText = label.subText,
                                    icon = label.icon, color = label.color, key = label.key
                                }
                            end
                        else
                            if label.visible then
                                label.visible = false
                                batch[#batch + 1] = { id = id, action = 'hide' }
                                labelLastSent[id] = nil
                            end
                        end
                    else
                        if label.visible then
                            label.visible = false
                            batch[#batch + 1] = { id = id, action = 'hide' }
                            labelLastSent[id] = nil
                        end
                    end
                end
            end
        end

        if #batch > 0 then
            SendNUIMessage({ action = 'batchFloatingLabels', labels = batch })
        end
    end
    labelThreadRunning = false
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    if isMinigameActive then
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'hideMinigame' })
        if minigameTimeoutTimer then
            ClearTimeout(minigameTimeoutTimer)
            minigameTimeoutTimer = nil
        end
        isMinigameActive = false
        minigameCallback = nil
    end

    SetNuiFocus(false, false)
end)

return UI
