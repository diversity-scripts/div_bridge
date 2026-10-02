-------------------------------------------------------------------------------
-- ox_lib UI Adapter (Client)
-- Translates the bridge's standard UI format into ox_lib API calls.
-- Unsupported parameters are silently dropped.
-- Text is sanitized to strip custom formatting ox_lib doesn't understand.
-------------------------------------------------------------------------------

dBridge.loadOxLib()

local Adapter = {}

-------------------------------------------------------------------------------
-- Notification
-------------------------------------------------------------------------------

---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(data)
    lib.notify({
        title = data.title and dBridge.sanitize(data.title) or nil,
        description = dBridge.sanitize(data.text or data.message or ''),
        type = data.type or 'info',
        duration = data.duration or 5000
    })
end

-------------------------------------------------------------------------------
-- TextUI
-------------------------------------------------------------------------------

---@param text string
Adapter.ShowTextUI = function(text)
    lib.showTextUI(dBridge.sanitize(text))
end

Adapter.HideTextUI = function()
    lib.hideTextUI()
end

-------------------------------------------------------------------------------
-- Progress
-- Translates bridge standard format to ox_lib progressBar/progressCircle.
-- Drops unsupported params: subtitle, icon, stages, activeStage, colorScheme.
-------------------------------------------------------------------------------

---@param data table
---@return boolean
Adapter.Progress = function(data)
    local opts = {
        duration = data.duration or 3000,
        label = dBridge.sanitize(data.label or ''),
        useWhileDead = false,
        canCancel = data.cancelKey ~= nil,
        position = data.position or 'bottom',
    }

    if data.type == 'circle' then
        return lib.progressCircle(opts)
    else
        return lib.progressBar(opts)
    end
end

-------------------------------------------------------------------------------
-- Context Menu
-- Translates bridge standard format to ox_lib registerContext/showContext.
-- Drops unsupported params: progress, colorScheme, iconAnimation.
-------------------------------------------------------------------------------

Adapter.RegisterContext = function(data)
    if not data or not data.id then return end

    local options = {}
    for _, opt in ipairs(data.options or {}) do
        local entry = {
            title = opt.title,
            description = opt.description and dBridge.sanitize(opt.description) or nil,
            icon = opt.icon,
            arrow = opt.arrow,
            disabled = opt.disabled,
            readOnly = opt.readOnly,
            image = opt.image,
            metadata = opt.metadata,
            menu = opt.menu,
            event = opt.event,
            serverEvent = opt.serverEvent,
            args = opt.args,
        }
        if opt.onSelect then
            entry.onSelect = opt.onSelect
        end
        options[#options + 1] = entry
    end

    lib.registerContext({
        id = data.id,
        title = data.title,
        menu = data.menu,
        canClose = data.canClose,
        onExit = data.onExit,
        onBack = data.onBack,
        options = options
    })
end

Adapter.ShowContext = function(id)
    lib.showContext(id)
end

Adapter.HideContext = function()
    lib.hideContext()
end

-------------------------------------------------------------------------------
-- Input Dialog
-- Translates bridge standard format to ox_lib inputDialog.
-- Drops unsupported types: range-slider, time, color (falls back to input).
-------------------------------------------------------------------------------

Adapter.InputDialog = function(heading, rows, options)
    local oxRows = {}
    for _, row in ipairs(rows or {}) do
        local oxRow = {
            type = row.type or 'input',
            label = row.label,
            description = row.description and dBridge.sanitize(row.description) or nil,
            icon = row.icon,
            placeholder = row.placeholder,
            default = row.default,
            required = row.required,
            min = row.min,
            max = row.max,
        }

        -- Map types ox_lib supports
        if row.type == 'select' or row.type == 'multi-select' then
            oxRow.options = row.options
            if row.searchable then
                oxRow.searchable = true
            end
        elseif row.type == 'slider' then
            oxRow.type = 'slider'
            oxRow.step = row.step
        elseif row.type == 'checkbox' then
            oxRow.type = 'checkbox'
            oxRow.checked = row.default
        elseif row.type == 'date' or row.type == 'date-range' then
            oxRow.type = 'date'
        elseif row.type == 'textarea' then
            oxRow.type = 'textarea'
        elseif row.type == 'number' then
            oxRow.type = 'number'
        elseif row.type == 'color' or row.type == 'time' or row.type == 'range-slider' then
            -- ox_lib doesn't support these; fall back to basic input
            oxRow.type = 'input'
            oxRow.placeholder = row.placeholder or ('Enter ' .. (row.label or 'value'))
        end

        oxRows[#oxRows + 1] = oxRow
    end

    local result = lib.inputDialog(heading, oxRows, options and options.allowCancel and 'cancel' or nil)
    return result
end

-------------------------------------------------------------------------------
-- Skill Check
-- ox_lib has its own skillCheck; translate difficulty format.
-------------------------------------------------------------------------------

Adapter.SkillCheck = function(difficulty, key, callback)
    local diffData
    if type(difficulty) == 'table' then
        -- Custom difficulty: map areaSize to ox_lib's format
        diffData = { areaSize = difficulty.areaSize or 40, speedMultiplier = difficulty.speed or 1.5 }
    elseif difficulty == 'easy' then
        diffData = { areaSize = 60, speedMultiplier = 1.0 }
    elseif difficulty == 'medium' then
        diffData = { areaSize = 40, speedMultiplier = 1.5 }
    elseif difficulty == 'hard' then
        diffData = { areaSize = 25, speedMultiplier = 2.0 }
    else
        diffData = { areaSize = 40, speedMultiplier = 1.5 }
    end

    local success = lib.skillCheck({ diffData }, { key or 'e' })
    if callback then
        callback(success)
    end
end

return Adapter
