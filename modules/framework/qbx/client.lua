local QBCore = exports['qb-core']:GetCoreObject()
local qbx_core = exports.qbx_core
local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'qbx_core'
end

-- [[ Player Related ]] --

---This will return true if the player is loaded, false otherwise
---@return boolean
Framework.IsPlayerLoaded = function()
    return LocalPlayer.state.isLoggedIn or false
end

---This is an internal function, do not use this outside of bridge as there is no standard format between the frameworks
---@return table
Framework.GetPlayerData = function()
    return qbx_core:GetPlayerData()
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
    return playerData?.charinfo?.gender and (playerData.charinfo.gender == 0 and 'male' or 'female') or nil
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
    local playerData = Framework.GetPlayerData()
    return playerData?.metadata?.isdead or playerData?.metadata?.inlaststand or false
end

---This will return the players job
---@return table {name, label, grade, gradeLabel}
Framework.GetPlayerJob = function()
    local playerData = Framework.GetPlayerData()
    local job = playerData?.job or {}
    return playerData?.job and {
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
    local playerData = Framework.GetPlayerData()
    local playerJob = playerData?.job
    return playerJob and playerJob.name == jobName and (not jobGrade or tonumber(playerJob.grade.level) >= jobGrade)
end

---This will get the players group
---@return string | nil
Framework.GetPlayerGroup = function()
    return nil
end

---This will check for the closest player
---@return number playerId, number distance
Framework.GetClosestPlayer = function()
    return QBCore.Functions.GetClosestPlayer()
end

---This will check for the closest vehicle
---@return number vehicleId, number distance
Framework.GetClosestVehicle = function()
    return QBCore.Functions.GetClosestVehicle()
end

-- [[ UI Related ]] --

---This will send a notification to the player
---@param msg string
---@param _type? 'success' | 'error' | 'info' | 'warning'
---@param duration? number
Framework.Notify = function(msg, _type, duration)
    qbx_core:Notify(msg, _type, duration)
end

---This will display the help text message on the screen
---@param text string
Framework.ShowTextUI = function(text)
    exports.ox_lib:showTextUI(text)
end

---This will hide the help text message on the screen
Framework.HideTextUI = function()
    exports.ox_lib:hideTextUI()
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
    local balance = account[accountType] or 0
    if balance <= 0 then return 0 end
    return balance
end

-- [[ Inventory Related ]] --

---This is an internal function used as a fallback, please use the Inventory.GetItemCount instead.
---@param itemName string Item name
---@return number
Framework.GetItemCount = function(itemName)
    return 0, print('Qbox does not provide "GetItemCount" function.')
end

---This is an internal function used as a fallback, please use the Inventory.HasItem instead.
---@param itemName string Item name
---@param requiredCount number Item count (optional)
---@return boolean
Framework.HasItem = function(itemName, requiredCount)
    return false, print('Qbox does not provide "HasItem" function.')
end

---This is an internal function used as a fallback, please use the Inventory.GetPlayerInventory instead.
---@return table {name, label, count, slot, metadata, stack, close, weight}
Framework.GetPlayerInventory = function()
    return Framework.GetPlayerData().items
end

-- [[ Event Related ]] --

---Event handler for when player is loaded in
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1500)
    TriggerEvent('div_bridge/client/OnPlayerLoaded')
end)

---Event handler for when player logs out
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent('div_bridge/client/OnPlayerUnload')
end)

---Event handler for when player job is updated
---@param data table Job data containing name, label, grade_label, and grade
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(data)
    TriggerEvent('div_bridge/client/OnPlayerJobUpdate', data.name, data.label, data.grade_label, data.grade)
end)

return Framework