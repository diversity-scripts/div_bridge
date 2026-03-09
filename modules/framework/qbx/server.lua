local qbx_core = exports.qbx_core
local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'qbx_core'
end

-- [[ Player Related ]] --

---This will get player data from player ID
---@param source number
---@return table | nil
Framework.GetPlayerFromId = function(source)
    return qbx_core:GetPlayer(tonumber(source)) or nil
end

---This will get player data from player identifier
---@param identifier string
---@return table | nil
Framework.GetPlayerFromIdentifier = function(identifier)
    return qbx_core:GetPlayerByCitizenId(identifier) or nil
end

---This will get the players identifier (citizenid)
---@param source number
---@return string | nil
Framework.GetPlayerIdentifier = function(source)
    local player = Framework.GetPlayerFromId(source)
    return player?.PlayerData?.citizenid or nil
end

---This will get the players name
---@param source number
---@return table {fullName, firstName, lastName}
Framework.GetPlayerName = function(source)
    local player = Framework.GetPlayerFromId(source)
    if not player then return { fullName = '', firstName = '', lastName = '' } end
    local playerData = player.PlayerData?.charinfo
    return {
        fullName = (playerData?.firstname or '') .. ' ' .. (playerData?.lastname or ''),
        firstName = playerData?.firstname or '',
        lastName = playerData?.lastname or '',
    }
end

---This will get the players gender
---@param source number
---@return 'male' | 'female' | nil
Framework.GetPlayerGender = function(source)
    local player = Framework.GetPlayerFromId(source)
    if not player then return nil end
    return player.PlayerData?.charinfo?.gender or nil
end

---This will get the players birth date
---@param source number
---@return string
Framework.GetPlayerDob = function(source)
    local player = Framework.GetPlayerFromId(source)
    return player?.PlayerData?.charinfo?.birthdate or ''
end

---This will return the players job
---@param source number
---@return table {name, label, grade, gradeLabel}
Framework.GetPlayerJob = function(source)
    local player = Framework.GetPlayerFromId(source)
    if not player then return { name = '', label = '', grade = 0, gradeLabel = '' } end

    local job = player.PlayerData?.job
    return job and {
        name = job.name or '',
        label = job.label or '',
        grade = job.grade?.level or 0,
        gradeLabel = job.grade?.name or '',
    } or {
        name = '',
        label = '',
        grade = 0,
        gradeLabel = '',
    }
end

---This will set the players job
---@param source number
---@param jobName string
---@param jobGrade? number
Framework.SetPlayerJob = function(source, jobName, jobGrade)
    local player = Framework.GetPlayerFromId(source)
    if not player then return end

    local identifier = player.PlayerData?.citizenid
    qbx_core:SetJob(identifier, jobName, jobGrade or 0)
end

---This will return true if player has the job, false otherwise
---@param source number
---@param jobName string
---@param jobGrade? number
---@return boolean
Framework.PlayerHasJob = function(source, jobName, jobGrade)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end

    local currentJob = player.PlayerData?.job
    if not currentJob then return false end

    return currentJob.name == jobName and (not jobGrade or tonumber(currentJob.grade.level) >= jobGrade)
end

---This will return a number of all players with a specified job
---@param jobName string
---@return number
Framework.GetJobCount = function(jobName)
    local count = 0
    local players = qbx_core:GetQBPlayers()

    for src, _ in pairs(players) do
        local player = qbx_core:GetPlayer(src)

        if player then
            local job = player.PlayerData?.job

            if job.name == jobName and job.onduty then
                count = count + 1
            end
        end
    end

    return count
end

---This will return a table of all logged in players
---@return table
Framework.GetAllPlayers = function()
    return qbx_core:GetQBPlayers()
end

---Registers a usable item with a callback function
---@param itemName string Item name
---@param cb function Function to call when item is used
Framework.RegisterUsableItem = function(itemName, cb)
    local func = function(src, item, itemData)
        itemData = itemData or item
        itemData.metadata = itemData.metadata or itemData.info or {}
        itemData.slot = itemData.id or itemData.slot
        cb(src, itemData)
    end
    qbx_core:CreateUseableItem(itemName, func)
end

-- [[ Account Related ]] --

---This will add money to the player by account type
---@param source number
---@param accountType 'cash' | 'bank'
---@param amount number
---@return boolean
Framework.AddAccountBalance = function(source, accountType, amount)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end

    if amount <= 0 then return false end
    if accountType == 'money' then accountType = 'cash' end

    return player.Functions.AddMoney(accountType, amount)
end

---This will remove the players money by account type
---@param source number
---@param accountType 'cash' | 'bank'
---@param amount number
---@return boolean
Framework.RemoveAccountBalance = function(source, accountType, amount)
    local player = Framework.GetPlayer(source)
    if not player then return false end

    if amount <= 0 then return false end
    if accountType == 'money' then accountType = 'cash' end

    return player.Functions.RemoveMoney(accountType, amount)
end

---This will return the players money by account type
---@param source number
---@param accountType 'cash' | 'bank'
---@return number
Framework.GetAccountBalance = function(source, accountType)
    local player = Framework.GetPlayer(source)
    if not player then return 0 end

    if accountType == 'money' then accountType = 'cash' end
    local balance = player.PlayerData?.money[accountType] or 0
    return balance
end

-- [[ Event Related ]] --

---Event handler for when player is loaded in
---@param src number
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function(src)
    src = src or source
    TriggerEvent('div_bridge/server/OnPlayerLoaded', src)
end)

---Event handler for when player logs out
---@param src number
RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(src)
    src = src or source
    TriggerEvent('div_bridge/server/OnPlayerUnload', src)
end)

---Event handler for when player job is updated
---@param src number
---@param job table
RegisterNetEvent('QBCore:Server:OnJobUpdate', function(src, job)
    src = src or source
    if not job then return end
    TriggerEvent('div_bridge/server/OnPlayerJobChange', src, job.name)
end)

---Event handler for when a player disconnects from the server
AddEventHandler('playerDropped', function()
    local src = source
    TriggerEvent('div_bridge/server/OnPlayerUnload', src)
end)

return Framework