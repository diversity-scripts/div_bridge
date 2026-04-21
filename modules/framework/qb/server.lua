local QBCore = exports['qb-core']:GetCoreObject()
local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'qb-core'
end

-- [[ Player Related ]] --

---This will get player data from player ID
---@param source number
---@return table | nil
Framework.GetPlayerFromId = function(source)
    return QBCore.Functions.GetPlayer(tonumber(source)) or nil
end

---This will get player data from player identifier
---@param identifier string
---@return table | nil
Framework.GetPlayerFromIdentifier = function(identifier)
    return QBCore.Functions.GetPlayerByCitizenId(identifier) or nil
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
    return player?.PlayerData?.charinfo?.gender or nil
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
---@return boolean
Framework.SetPlayerJob = function(source, jobName, jobGrade)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end
    return player.Functions.SetJob(jobName, jobGrade)
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
    local players = QBCore.Functions.GetPlayers()

    for _, src in pairs(players) do
        local player = QBCore.Functions.GetPlayer(src)

        if player then
            local job = player.PlayerData.job

            if job.name == jobName and job.onduty then
                count = count + 1
            end
        end
    end

    return count
end

---This will return the players group
---@param source number
---@return string | nil
Framework.GetPlayerGroup = function(source)
    local perms = QBCore.Functions.GetPermission(source)
    return perms
end

---This will return a table of all logged in players
---@return table
Framework.GetAllPlayers = function()
    return QBCore.Functions.GetPlayers()
end

---This will return the jobs registered in the framework
---@return table
Framework.GetFrameworkJobs = function()
    return QBCore.Shared.Jobs
end

-- [[ Inventory Related ]] --

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
    QBCore.Functions.CreateUseableItem(itemName, func)
end

---@param source number
---@param itemName string
---@param itemCount number
---@param metadata? table
---@param slot? number
---@return boolean
Framework.AddItem = function(source, itemName, itemCount, metadata, slot)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end
    return player.Functions.AddItem(itemName, itemCount or 1, slot, metadata or nil) or false
end

---@param source number
---@param itemName string
---@param itemCount number
---@param metadata? table
---@param slot? number
---@return boolean
Framework.RemoveItem = function(source, itemName, itemCount, metadata, slot)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end

    if not slot and metadata then
        local inv = player.PlayerData?.items or {}
        for _, v in pairs(inv) do
            if v.name == itemName and (v.info or v.metadata) == metadata then
                slot = v.slot
                break
            end
        end
    end

    if slot then
        return player.Functions.RemoveItem(itemName, itemCount or 1, slot) or false
    end

    return player.Functions.RemoveItem(itemName, itemCount or 1) or false
end

---@param source number
---@param itemName string
---@param itemCount number
---@param metadata? table
---@return boolean
Framework.CanCarryItem = function(source, itemName, itemCount, metadata)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end
    return QBCore.Functions.CanCarryItem(player, itemName, itemCount or 1)
end

---@param source number
---@param items string | string[]
---@return number
Framework.GetItemCount = function(source, items)
    local player = Framework.GetPlayerFromId(source)
    if not player then return 0 end
    local inv = player.PlayerData?.items or {}
    local names = type(items) == 'table' and items or { items }
    local wanted = {}
    for _, name in pairs(names) do wanted[name] = true end
    local count = 0
    for _, v in pairs(inv) do
        if wanted[v.name] then
            count = count + (v.amount or v.count or v.quantity or 0)
        end
    end
    return count
end

---@param source number
---@param items string | string[]
---@param itemCount number
---@return boolean
Framework.HasItem = function(source, items, itemCount)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end
    local inv = player.PlayerData?.items or {}
    local names = type(items) == 'table' and items or { items }
    local required = itemCount or 1
    for _, name in pairs(names) do
        local total = 0
        for _, v in pairs(inv) do
            if v.name == name then
                total = total + (v.amount or v.count or 0)
            end
        end
        if total < required then
            return false
        end
    end
    return true
end

---@param source number
---@param itemName string
---@param metadata? table
---@param slot? number
---@return table
Framework.GetItemData = function(source, itemName, metadata, slot)
    local player = Framework.GetPlayerFromId(source)
    if not player then return {} end
    if slot then
        local item = player.Functions.GetItemBySlot(slot)
        return item or {}
    end
    local item = player.Functions.GetItemByName(itemName)
    return item or {}
end

---@param source number
---@param itemName string
---@param metadata? table
---@param slot? number
---@return table
Framework.GetItemByName = function(source, itemName, metadata, slot)
    return Framework.GetItemData(source, itemName, metadata, slot)
end

---@param source number
---@param slot number
---@return table
Framework.GetItemBySlot = function(source, slot)
    local player = Framework.GetPlayerFromId(source)
    if not player then return {} end
    return player.Functions.GetItemBySlot(slot) or {}
end

---@param source number
---@return table
Framework.GetPlayerInventory = function(source)
    local player = Framework.GetPlayerFromId(source)
    if not player then return {} end
    return player.PlayerData?.items or {}
end

---@param source number
Framework.ClearPlayerInventory = function(source)
    local player = Framework.GetPlayerFromId(source)
    if not player then return end
    player.Functions.ClearInventory()
end

---@param source number
---@param slot number
---@param metadata table
Framework.SetMetadata = function(source, slot, metadata)
    local player = Framework.GetPlayerFromId(source)
    if not player then return end
    local item = player.Functions.GetItemBySlot(slot)
    if not item then return end
    local amount = item.amount or item.count or 1
    player.Functions.RemoveItem(item.name, amount, slot)
    player.Functions.AddItem(item.name, amount, slot, metadata or {})
end

---@param itemName string
---@return string
Framework.GetItemlabel = function(itemName)
    return QBCore.Shared?.Items[itemName]?.label or itemName
end

---@param itemName? string
---@return table
Framework.Items = function(itemName)
    return QBCore.Shared?.Items or {}
end

-- [[ Account Related ]] --

---This will return the players money by account type
---@param source number
---@param accountType 'cash' | 'bank'
---@return number
Framework.GetPlayerAccountBalance = function(source, accountType)
    local player = Framework.GetPlayerFromId(source)
    if not player then return 0 end

    if accountType == 'money' then accountType = 'cash' end
    local balance = player.PlayerData?.money[accountType] or 0
    return balance
end

---This will add money to the player by account type
---@param source number
---@param accountType 'cash' | 'bank'
---@param amount number
---@return boolean
Framework.AddPlayerAccountBalance = function(source, accountType, amount)
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
Framework.RemovePlayerAccountBalance = function(source, accountType, amount)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end

    if amount <= 0 then return false end
    if accountType == 'money' then accountType = 'cash' end

    return player.Functions.RemoveMoney(accountType, amount)
end

---This will return the job account money by account type
---@param accountId string | number
---@return number
Framework.GetJobAccountBalance = function(accountId)
    return 0, print('QBCore does not provide a "GetJobAccountBalance" function')
end

---This will add money to the job account by account type
---@param accountId string | number
---@param amount number
---@param reason? string
---@return boolean
Framework.AddJobAccountBalance = function(accountId, amount, reason)
    return false, print('QBCore does not provide a "AddJobAccountBalance" function')
end

---This will remove the job account money by account type
---@param accountId string | number
---@param amount number
---@param reason? string
---@return boolean
Framework.RemoveJobAccountBalance = function(accountId, amount, reason)
    return false, print('QBCore does not provide a "RemoveJobAccountBalance" function')
end

-- [[ Event Related ]] --

---Event handler for when player is loaded in
---@param player number
RegisterNetEvent('QBCore:Server:PlayerLoaded', function(player)
    src = player.PlayerData.source or source
    TriggerEvent('div_bridge:server:OnPlayerLoaded', src)
end)

---Event handler for when player logs out
---@param player number
RegisterNetEvent('QBCore:Server:PlayerDropped', function(player)
    src = player.PlayerData.source or source
    TriggerEvent('div_bridge:server:OnPlayerUnloaded', src)
end)

---Event handler for when player job is updated
---@param src number
---@param job table
RegisterNetEvent('QBCore:Server:OnJobUpdate', function(src, job)
    src = src or source
    TriggerEvent('div_bridge:server:OnPlayerJobChange', { playerId = src, name = job.name, label = job.label, grade = job.grade.level, gradeLabel = job.grade.name })
end)

return Framework
