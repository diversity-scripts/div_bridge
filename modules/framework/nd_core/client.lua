Bridge.loadOxLib()
local NDCore = exports['ND_Core']
local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'ND_Core'
end

-- [[ Player Related ]] --

---This will return true if the player is loaded, false otherwise
---@return boolean
Framework.IsPlayerLoaded = function()
    local playerData = NDCore:getPlayer()
    return playerData?.identifier or false
end

---This is an internal function, do not use this outside of bridge as there is no standard format between the frameworks
---@return table
Framework.GetPlayerData = function()
    return NDCore:getPlayer()
end

---This will get the players identifier (citizenid)
---@return string | nil
Framework.GetPlayerIdentifier = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.identifier or nil
end

---This will get the players name
---@return table {fullName, firstName, lastName}
Framework.GetPlayerName = function()
    local playerData = Framework.GetPlayerData()
    if not playerData then return { fullName = '', firstName = '', lastName = '' } end
    return {
        fullName = playerData.fullname,
        firstName = playerData.firstname or '',
        lastName = playerData.lastname or '',
    }
end

---This will get the players gender
---@return 'male' | 'female' | nil
Framework.GetPlayerGender = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.gender or nil
end

---This will get the players birth date
---@return string
Framework.GetPlayerDob = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.dob or ''
end

---This will get a players dead status
---@return boolean
Framework.IsPlayerDead = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.metadata?.currentlyDead or false
end

---This will return the players job
---@return table {name, label, grade, gradeLabel}
Framework.GetPlayerJob = function()
    local playerData = Framework.GetPlayerData()
    if not playerData then return { name = '', label = '', grade = 0, gradeLabel = '' } end

    local job = playerData?.job or nil
    local jobInfo = playerData?.jobInfo or nil
    local grade = jobInfo?.grade or nil

    return job and {
        name = job,
        label = jobInfo?.label or '',
        grade = grade or 0,
        gradeLabel = jobInfo?.rankName or '',
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

    local job = playerData.job or {}
    local jobInfo = playerData.jobInfo or {}

    return job == jobName and (not jobGrade or jobInfo.rank >= jobGrade)
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
    NDCore:notify({
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
    local playerData = Framework.GetPlayerData()
    if not playerData then return 0 end
    if accountType == 'money' then accountType = 'cash' end
    return playerData[accountType] or 0
end

-- [[ Inventory Related ]] --

---This is an internal function used as a fallback, please use the Inventory.GetItemCount instead.
---@param itemName string Item name
---@return number
Framework.GetItemCount = function(itemName)
    return 0, print('nd_core does not provide "GetItemCount" function.')
end

---This is an internal function used as a fallback, please use the Inventory.HasItem instead.
---@param itemName string Item name
---@param requiredCount number Item count (optional)
---@return boolean
Framework.HasItem = function(itemName, requiredCount)
    return false, print('nd_core does not provide "HasItem" function.')
end

---This is an internal function used as a fallback, please use the Inventory.GetPlayerInventory instead.
---@return table {name, label, count, slot, metadata, stack, close, weight}
Framework.GetPlayerInventory = function()
    return {}, print('nd_core does not provide "GetPlayerInventory" function.')
end

-- [[ Event Related ]] --

---Event handler for when player is loaded in
AddEventHandler('ND:characterLoaded', function()
    Wait(1500)
    TriggerEvent('div_bridge/client/OnPlayerLoaded')
end)

---Event handler for when player logs out
AddEventHandler('ND:characterUnloaded', function()
    TriggerEvent('div_bridge/client/OnPlayerUnload')
end)

---Event handler for when player job is updated
---@param character table Player data
AddEventHandler('ND:updateCharacter', function(character)
    if not character.job or not character.jobInfo then return end
    local jobInfo = character.jobInfo
    TriggerEvent('div_bridge/client/OnPlayerJobUpdate', character.job, jobInfo.label, jobInfo.rankName, jobInfo.rank)
end)

return Framework