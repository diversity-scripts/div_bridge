Bridge.loadOxLib()
local Ox = require '@ox_core/lib/init'
local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'ox_core'
end

-- [[ Player Related ]] --

---This will return true if the player is loaded, false otherwise
---@return boolean
Framework.IsPlayerLoaded = function()
    local playerData = Ox.GetPlayer()
    return playerData?.charId or false
end

---This is an internal function, do not use this outside of bridge as there is no standard format between the frameworks
---@return table
Framework.GetPlayerData = function()
    return Ox.GetPlayer()
end

---This will get the players identifier (citizenid)
---@return string | nil
Framework.GetPlayerIdentifier = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.charId or nil
end

---This will get the players name
---@return table {fullName, firstName, lastName}
Framework.GetPlayerName = function()
    local playerData = Framework.GetPlayerData()
    if not playerData then return { fullName = '', firstName = '', lastName = '' } end
    return {
        fullName = (playerData.get('firstName') or '') .. ' ' .. (playerData.get('lastName') or ''),
        firstName = playerData.get('firstName') or '',
        lastName = playerData.get('lastName') or '',
    }
end

---This will get the players gender
---@return 'male' | 'female' | nil
Framework.GetPlayerGender = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.get('gender') or nil
end

---This will get the players birth date
---@return string
Framework.GetPlayerDob = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.get('dateOfBirth') or ''
end

---This will get a players dead status
---@return boolean
Framework.IsPlayerDead = function()
    return LocalPlayer.state.isDead or false
end

---This will return the players job
---@return table {name, label, grade, gradeLabel}
Framework.GetPlayerJob = function()
    local playerData = Framework.GetPlayerData()
    if not playerData then return { name = '', label = '', grade = 0, gradeLabel = '' } end

    local activeGroup = playerData?.get('activeGroup')
    local grade = playerData?.getGroup(activeGroup)
    local groupData = activeGroup and GlobalState[('group.%s'):format(activeGroup)]

    return activeGroup and {
        name = activeGroup,
        label = groupData?.label or '',
        grade = grade or 0,
        gradeLabel = groupData?.grades[grade]?.label or '',
    } or {
        name = '',
        label = '',
        grade = 0,
        gradeLabel = '',
    }
end

---This will return true if player has the job, false otherwise
---@param jobName string
---@param jobGrade? number
---@return boolean
Framework.PlayerHasJob = function(jobName, jobGrade)
    local playerData = Framework.GetPlayerData()
    if not playerData then return false end

    local filter = jobGrade and { [jobName] = jobGrade } or jobName
    local hasJob = playerData.getGroup(filter)

    return hasJob and true or false
end

---This will get the players group
---@return string | nil
Framework.GetPlayerGroup = function()
    return nil
end

---This will check for the closest player
---@param distance? number
---@return number playerId, number distance
Framework.GetClosestPlayer = function(distance)
    local coords = GetEntityCoords(cache.ped)
    local closestPlayer, _, closestCoords = lib.getClosestPlayer(coords, distance or 10, false)
    return closestPlayer, #(coords - closestCoords)
end

---This will check for the closest vehicle
---@param distance? number
---@return number vehicleId, number distance
Framework.GetClosestVehicle = function(distance)
    local coords = GetEntityCoords(cache.ped)
    local closestVehicle, _, closestCoords = lib.getClosestVehicle(coords, distance or 10, false)
    return closestVehicle, #(coords - closestCoords)
end

-- [[ UI Related ]] --

---This will send a notification to the player
---@param message string
---@param type? 'success' | 'error' | 'info' | 'warning'
---@param duration? number
Framework.Notify = function(message, type, duration)
    lib.notify({
        description = message,
        type = type or 'info',
        duration = duration or 5000
    })
end

---This will display the help text message on the screen
---@param text string
Framework.ShowTextUI = function(text)
    lib.showTextUI(text)
end

---This will hide the help text message on the screen
Framework.HideTextUI = function()
    lib.hideTextUI()
end

-- [[ Account Related ]] --

---This will return the players money by account type
---@param accountType 'cash' | 'bank'
---@return number
Framework.GetAccountBalance = function(accountType)
    return 0, print('ox_core does not provide account balance.')
end

-- [[ Inventory Related ]] --

---This is an internal function used as a fallback, please use the Inventory.GetItemCount instead.
---@param itemName string Item name
---@return number
Framework.GetItemCount = function(itemName)
    return 0, print('ox_core does not provide "GetItemCount" function.')
end

---This is an internal function used as a fallback, please use the Inventory.HasItem instead.
---@param itemName string Item name
---@param requiredCount number Item count (optional)
---@return boolean
Framework.HasItem = function(itemName, requiredCount)
    return false, print('ox_core does not provide "HasItem" function.')
end

---This is an internal function used as a fallback, please use the Inventory.GetPlayerInventory instead.
---@return table {name, label, count, slot, metadata, stack, close, weight}
Framework.GetPlayerInventory = function()
    return {}, print('ox_core does not provide "GetPlayerInventory" function.')
end

-- [[ Event Related ]] --

---Event handler for when player is loaded in
RegisterNetEvent('ox:playerLoaded', function()
    Wait(1500)
    TriggerEvent('div_bridge:client:OnPlayerLoaded')
end)

---Event handler for when player logs out
RegisterNetEvent('ox:playerLogout', function()
    TriggerEvent('div_bridge:client:OnPlayerUnloaded')
end)

---Event handler for when player job is updated
---@param groupName string
---@param grade? number
RegisterNetEvent('ox:setGroup', function(groupName, grade)
    local data = GlobalState[('group.%s'):format(groupName)]
    local label = data?.label or 'N/A'
    local gradeLabel = grade and data?.grades[grade]?.label or 0
    TriggerEvent('div_bridge:client:OnPlayerJobUpdate', { name = groupName, label = label, grade = grade or 0, gradeLabel = gradeLabel })
end)

return Framework
