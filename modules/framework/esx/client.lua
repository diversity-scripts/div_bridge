local ESX = exports.es_extended:getSharedObject()
local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'es_extended'
end

-- [[ Player Related ]] --

---This will return true if the player is loaded, false otherwise
---@return boolean
Framework.IsPlayerLoaded = function()
    return ESX.IsPlayerLoaded()
end

---This is an internal function, do not use this outside of bridge as there is no standard format between the frameworks
---@return table
Framework.GetPlayerData = function()
    return ESX.GetPlayerData()
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
        fullName = (playerData.firstName or '') .. ' ' .. (playerData.lastName or ''),
        firstName = playerData.firstName or '',
        lastName = playerData.lastName or '',
    }
end

---This will get the players gender
---@return 'male' | 'female' | nil
Framework.GetPlayerGender = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.sex and (playerData.sex == 'm' and 'male' or 'female') or nil
end

---This will get the players birth date
---@return string
Framework.GetPlayerDob = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.dateofbirth or ''
end

---This will get a players dead status
---@return boolean
Framework.IsPlayerDead = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.dead or false
end

---This will return the players job
---@return table {name, label, grade, gradeLabel}
Framework.GetPlayerJob = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.job and {
        name = playerData.job.name,
        label = playerData.job.label,
        grade = playerData.job.grade,
        gradeLabel = playerData.job.grade_label,
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
    return playerJob and playerJob.name == jobName and (not jobGrade or tonumber(playerJob.grade) >= jobGrade)
end

---This will get the players group
---@return string | nil
Framework.GetPlayerGroup = function()
    local playerData = Framework.GetPlayerData()
    return playerData?.group or nil
end

---This will check for the closest player
---@return number playerId, number distance
Framework.GetClosestPlayer = function()
    return ESX.Game.GetClosestPlayer()
end

---This will check for the closest vehicle
---@return number vehicleId, number distance
Framework.GetClosestVehicle = function()
    return ESX.Game.GetClosestVehicle()
end

-- [[ UI Related ]] --

---This will send a notification to the player
---@param msg string
---@param _type? 'success' | 'error' | 'info' | 'warning'
---@param duration? number
Framework.Notify = function(msg, _type, duration)
    ESX.ShowNotification(msg, _type, duration)
end

---This will display the help text message on the screen
---@param text string
Framework.ShowTextUI = function(text)
    exports.esx_textui:TextUI(text, 'info')
end

---This will hide the help text message on the screen
Framework.HideTextUI = function()
    exports.esx_textui:HideUI()
end

-- [[ Account Related ]] --

---This will return the players money by account type
---@param accountType 'money' | 'bank'
---@return number
Framework.GetAccountBalance = function(accountType)
    local playerData = Framework.GetPlayerData()
    if not playerData then return 0 end
    local accounts = playerData.accounts
    if accountType == 'cash' then accountType = 'money' end
    for _, account in ipairs(accounts) do
        if account.name == accountType then
            if not account.money or account.money <= 0 then return 0 end
            return account.money or 0
        end
    end
    return 0
end

-- [[ Inventory Related ]] --

---This is an internal function used as a fallback, please use the Inventory.GetItemCount instead.
---@param itemName string Item name
---@return number
Framework.GetItemCount = function(itemName)
    local inventory = Framework.GetPlayerInventory()
    if not inventory or not inventory[itemName] then return 0 end
    return inventory[itemName].count or 0
end

---This is an internal function used as a fallback, please use the Inventory.HasItem instead.
---@param itemName string Item name
---@param requiredCount number Item count (optional)
---@return boolean
Framework.HasItem = function(itemName, requiredCount)
    local hasItem = ESX.SearchInventory(itemName, true)
    return hasItem >= (requiredCount or 1)
end

---This is an internal function used as a fallback, please use the Inventory.GetPlayerInventory instead.
---@return table {name, label, count, slot, metadata, stack, close, weight}
Framework.GetPlayerInventory = function()
    local playerData = Framework.GetPlayerData()
    if not playerData then return {} end
    local repack = {}
    for _, v in pairs(playerData.inventory) do
        repack[v.name] = {
            name = v.name,
            label = v.label,
            count = v.count,
            slot = 0,
            metadata = {},
            stack = false,
            close = v.usable or false,
            weight = v.weight or 0,
        }
    end
    return repack
end

-- [[ Event Related ]] --

---Event handler for when player is loaded in
RegisterNetEvent('esx:playerLoaded', function()
    Wait(1500)
    TriggerEvent('div_bridge:client:OnPlayerLoaded')
end)

---Event handler for when player logs out
RegisterNetEvent('esx:onPlayerLogout', function()
    TriggerEvent('div_bridge:client:OnPlayerUnloaded')
end)

---Event handler for when player disconnects from the server
RegisterNetEvent('esx:playerDropped', function()
    TriggerEvent('div_bridge:client:OnPlayerUnloaded')
end)

---Event handler for when player job is updated
---@param data table
RegisterNetEvent('esx:setJob', function(data)
    TriggerEvent('div_bridge:client:OnPlayerJobUpdate', { name = data.name, label = data.label, grade = data.grade, gradeLabel = data.grade_label })
end)

return Framework
