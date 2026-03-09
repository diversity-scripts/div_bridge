local TMC = exports.core:getCoreObject()
local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'core'
end

-- [[ Player Related ]] --

---This will return true if the player is loaded, false otherwise
---@return boolean
Framework.IsPlayerLoaded = function()
    return TMC.Functions.IsPlayerLoaded()
end

---This is an internal function, do not use this outside of bridge as there is no standard format between the frameworks
---@return table
Framework.GetPlayerData = function()
    return TMC.Functions.GetPlayerData()
end

---This will get the players identifier (citizenid)
---@return string | nil
Framework.GetPlayerIdentifier = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.citizenid or nil
end

---This will get the players name
---@return table {fullName, firstName, lastName}
Framework.GetPlayerName = function()
    local playerData = Framework.GetPlayerData()
    if not playerData or not playerData.charinfo then return { fullName = '', firstName = '', lastName = '' } end
    return {
        fullName = (playerData.charinfo.firstname or '') .. ' ' .. (playerData.charinfo.lastname or ''),
        firstName = playerData.charinfo.firstname or '',
        lastName = playerData.charinfo.lastname or '',
    }
end

---This will get the players gender
---@return 'male' | 'female' | nil
Framework.GetPlayerGender = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.charinfo?.gender and (playerData.charinfo.gender == 'M' and 'male' or 'female') or nil
end

---This will get the players birth date
---@return string
Framework.GetPlayerDob = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.charinfo?.birthdate or ''
end

---This will get a players dead status
---@return boolean
Framework.IsPlayerDead = function()
    return TMC.Functions.IsDead() or false
end

---This will return the players job
---@return table {name, label, grade, gradeLabel}
Framework.GetPlayerJob = function()
    local playerData = Framework.GetPlayerData()
    local job = playerData?.jobs[1] or {}
    return job and {
        name = job.name,
        label = job.label,
        grade = job.grade.level,
        gradeLabel = job.grade.name,
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
    local hasJob = TMC.Functions.HasJob(jobName, jobGrade)
    return hasJob or false
end

---This will get the players group
---@return string | nil
Framework.GetPlayerGroup = function()
    return nil
end

---This will check for the closest player
---@return number playerId, number distance
Framework.GetClosestPlayer = function()
    return TMC.Functions.GetClosestPlayer()
end

---This will check for the closest vehicle
---@return number vehicleId, number distance
Framework.GetClosestVehicle = function()
    return TMC.Functions.GetClosestVehicle()
end

-- [[ UI Related ]] --

---This will send a notification to the player
---@param msg string
---@param _type? 'success' | 'error' | 'info' | 'warning'
---@param duration? number
Framework.Notify = function(msg, _type, duration)
    TMC.Functions.SimpleNotify(msg, _type or 'info', duration or 5000)
end

---This will display the help text message on the screen
---@param text string
Framework.ShowTextUI = function(text)
    print('TMC does not provide TextUI functions.')
end

---This will hide the help text message on the screen
Framework.HideTextUI = function()
    print('TMC does not provide TextUI functions.')
end

-- [[ Account Related ]] --

---This will return the players money by account type
---@param accountType 'cash' | 'bank'
---@return number
Framework.GetAccountBalance = function(accountType)
    local playerData = Framework.GetPlayerData()
    if not playerData then return 0 end
    local account = playerData.money
    if accountType == 'money' then accountType = 'cash' end
    return account[accountType] or 0
end

-- [[ Inventory Related ]] --

---This is an internal function used as a fallback, please use the Inventory.GetItemCount instead.
---@param itemName string Item name
---@return number
Framework.GetItemCount = function(itemName)
    return TMC.Functions.GetItemAmountByName(itemName)
end

---This is an internal function used as a fallback, please use the Inventory.HasItem instead.
---@param itemName string Item name
---@param requiredCount number Item count (optional)
---@return boolean
Framework.HasItem = function(itemName, requiredCount)
    local count = TMC.Functions.GetItemAmountByName(itemName)
    requiredCount = requiredCount or 1
    return count >= requiredCount
end

---This is an internal function used as a fallback, please use the Inventory.GetPlayerInventory instead.
---@return table {name, label, count, slot, metadata, stack, close, weight}
Framework.GetPlayerInventory = function()
    local items = {}
    local frameworkInv = TMC.Functions.GetPlayerItems()
    for _, v in pairs(frameworkInv) do
        table.insert(items, {
            name = v.name,
            label = v.label,
            count = v.amount or v.count,
            slot = v.slot,
            metadata = v.info or v.metadata or {},
            stack = v.unique,
            close = v.useable,
            weight = v.weight
        })
    end
    return items
end

-- [[ Event Related ]] --

---Event handler for when player is loaded in
RegisterNetEvent('TMC:Client:OnPlayerLoaded', function()
    Wait(1500)
    TriggerEvent('div_bridge/client/OnPlayerLoaded')
end)

---Event handler for when player logs out
RegisterNetEvent('TMC:Client:OnPlayerUnloaded', function()
    TriggerEvent('div_bridge/client/OnPlayerUnload')
end)

return Framework