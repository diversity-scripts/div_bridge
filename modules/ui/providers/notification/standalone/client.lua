local Adapter = {}

---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(data)
    local message = dBridge.sanitize(data.text or data.message or '')
    local _type = data.type

    if _type == 'error' then
        message = '~r~' .. message
    elseif _type == 'warning' then
        message = '~y~' .. message
    elseif _type == 'success' then
        message = '~g~' .. message
    elseif _type == 'info' then
        message = '~b~' .. message
    end

    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(true, false)
end

-------------------------------------------------------------------------------
-- TextUI (scaleform-based instructional buttons)
-------------------------------------------------------------------------------
local scaleform = nil

---@param text string
Adapter.Show = function(text)
    text = dBridge.sanitize(text)
    local buttons = {}
    if type(text) == 'string' then
        for line in text:gmatch('[^\n]+') do
            buttons[#buttons + 1] = { label = line }
        end
        if #buttons == 0 then
            buttons[1] = { label = text }
        end
    elseif type(text) == 'table' then
        for _, v in ipairs(text) do
            if type(v) == 'string' then
                buttons[#buttons + 1] = { label = v }
            elseif type(v) == 'table' then
                buttons[#buttons + 1] = { label = v.label or '', controls = v.controls }
            end
        end
    end

    scaleform = RequestScaleformMovie('INSTRUCTIONAL_BUTTONS')
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end

    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 0, 0)
    CallScaleformMovieMethod(scaleform, 'CLEAR_ALL')
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, 'SET_CLEAR_SPACE')
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    for i, button in ipairs(buttons) do
        local slotIndex = i - 1
        BeginScaleformMovieMethod(scaleform, 'SET_DATA_SLOT')
        ScaleformMovieMethodAddParamInt(slotIndex)

        if type(button.controls) == 'string' then
            ---@diagnostic disable-next-line: param-type-mismatch
            ScaleformMovieMethodAddParamPlayerNameString(button.controls)
        elseif type(button.controls) == 'table' then
            ---@diagnostic disable-next-line: param-type-mismatch
            for _, control in ipairs(button.controls) do
                ScaleformMovieMethodAddParamPlayerNameString(control)
            end
        end

        BeginTextCommandScaleformString('STRING')
        AddTextComponentSubstringKeyboardDisplay(button.label)
        EndTextCommandScaleformString()
        PopScaleformMovieFunctionVoid()
    end

    PushScaleformMovieFunction(scaleform, 'DRAW_INSTRUCTIONAL_BUTTONS')
    PopScaleformMovieFunctionVoid()

    CreateThread(function()
        while scaleform do
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
            Wait(0)
        end
    end)
end

Adapter.Hide = function()
    if scaleform then
        SetScaleformMovieAsNoLongerNeeded(scaleform)
        scaleform = nil
    end
end

return Adapter
