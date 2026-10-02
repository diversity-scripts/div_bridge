local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'standalone'
end

-- [[ Player Related ]] --

---This will return true if the player is loaded, false otherwise
---@return boolean
Framework.IsPlayerLoaded = function()
    return true
end

---This will get the players identifier (citizenid)
---@return string | nil
Framework.GetPlayerIdentifier = function()
    return nil, print('Framework does not provide a "GetPlayerIdentifier" function.')
end

---This will get the players name
---@return table {fullName, firstName, lastName}
Framework.GetPlayerName = function()
    local playerName = GetPlayerName(PlayerId())
    return {
        fullName = playerName or '',
        firstName = playerName or '',
        lastName = playerName or '',
    }
end

---This will get the players gender
---@return 'male' | 'female' | nil
Framework.GetPlayerGender = function()
    local playerModel = GetEntityModel(PlayerPedId())
    if playerModel == `mp_m_freemode_01` then
        return 'male'
    elseif playerModel == `mp_f_freemode_01` then
        return 'female'
    else
        return nil
    end
end

---This will get the players birth date
---@return string
Framework.GetPlayerDob = function()
    return '', print('Framework does not provide a "GetPlayerDob" function.')
end

---This will get a players dead status
---@return boolean
Framework.IsPlayerDead = function()
    return IsEntityDead(PlayerPedId())
end

---This will return the players job
---@return table {name, label, grade, gradeLabel}
Framework.GetPlayerJob = function()
    return {
        name = '',
        label = '',
        grade = 0,
        gradeLabel = '',
    }, print('Framework does not provide a "GetPlayerJob" function.')
end

---This will return true if player has the job, false otherwise
---@param jobName string
---@param jobGrade? number
---@return boolean
Framework.PlayerHasJob = function(jobName, jobGrade)
    return true, print('Framework does not provide a "PlayerHasJob" function.')
end

---This will get the players group
---@return string | nil
Framework.GetPlayerGroup = function()
    return nil, print('Framework does not provide a "GetPlayerGroup" function.')
end

---This will check for the closest player
---@param maxDistance? number Maximum search distance. Defaults to 10.0.
---@return number | nil playerId, number | nil distance
Framework.GetClosestPlayer = function(maxDistance)
    maxDistance = maxDistance or 10.0
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestPlayer, closestDistance = nil, maxDistance

    for _, player in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= playerPed and DoesEntityExist(targetPed) then
            local distance = #(playerCoords - GetEntityCoords(targetPed))
            if distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end

    if not closestPlayer then return nil, nil end
    return closestPlayer, closestDistance
end

---This will check for the closest vehicle
---@param maxDistance? number Maximum search distance. Defaults to 10.0.
---@return number | nil vehicleId, number | nil distance
Framework.GetClosestVehicle = function(maxDistance)
    maxDistance = maxDistance or 10.0
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closestVehicle, closestDistance = nil, maxDistance

    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        local distance = #(playerCoords - GetEntityCoords(vehicle))
        if distance < closestDistance then
            closestVehicle = vehicle
            closestDistance = distance
        end
    end

    if not closestVehicle then return nil, nil end
    return closestVehicle, closestDistance
end

-- [[ UI Related ]] --

---This will send a notification to the player
---@param msg string
---@param _type? 'success' | 'error' | 'info' | 'warning'
---@param duration? number
Framework.Notify = function(msg, _type, duration)
    local message = dBridge.sanitize(msg or '')

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

---This will display the help text message on the screen
---@param text string
Framework.ShowTextUI = function(text)
    print('Standalone does not provide a "ShowTextUI" function.')
end

---This will hide the help text message on the screen
Framework.HideTextUI = function()
    print('Standalone does not provide a "HideTextUI" function.')
end

-- [[ Account Related ]] --

---This will return the players money by account type
---@param accountType 'money' | 'bank'
---@return number
Framework.GetAccountBalance = function(accountType)
    return 0, print('Framework does not provide a "GetAccountBalance" function.')
end

-- [[ Inventory Related ]] --

---This is an internal function used as a fallback, please use the Inventory.GetItemCount instead.
---@param itemName string Item name
---@return number
Framework.GetItemCount = function(itemName)
    return 0, print('Framework does not provide a "GetItemCount" function.')
end

---This is an internal function used as a fallback, please use the Inventory.HasItem instead.
---@param itemName string Item name
---@param requiredCount number Item count (optional)
---@return boolean
Framework.HasItem = function(itemName, requiredCount)
    return false, print('Framework does not provide a "HasItem" function.')
end

---This is an internal function used as a fallback, please use the Inventory.GetPlayerInventory instead.
---@return table {name, label, count, slot, metadata, stack, close, weight}
Framework.GetPlayerInventory = function()
    return {}, print('Framework does not provide a "GetPlayerInventory" function.')
end

-- [[ Event Related ]] --

---Event handler for when player is loaded in
local isLoaded = false
AddEventHandler('playerSpawned', function()
    if not isLoaded then
        isLoaded = true
        Wait(1500)
        TriggerEvent('div_bridge:client:OnPlayerLoaded')
    end
end)

return Framework
