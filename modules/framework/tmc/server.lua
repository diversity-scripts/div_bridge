local TMC = exports.core:getCoreObject()
local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'core'
end

-- [[ Player Related ]] --

---This will get player data from player ID
---@param source number
---@return table | nil
Framework.GetPlayerFromId = function(source)
    return TMC.Functions.GetPlayer(tonumber(source)) or nil
end

---This will get player data from player identifier
---@param identifier string
---@return table | nil
Framework.GetPlayerFromIdentifier = function(identifier)
    local players = TMC.Functions.GetPlayers()
    for _, src in pairs(players) do
        local player = TMC.Functions.GetPlayer(src)
        if player and player.PlayerData?.citizenid == identifier then
            return player
        end
    end
    return nil
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
    local playerData = player.PlayerData?.charinfo
    return playerData?.gender and (playerData?.gender == 'M' and 'male' or 'female') or nil
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
    local player = TMC.Functions.GetPlayer(source)
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
    local player = TMC.Functions.GetPlayer(source)
    if not player then return false end

    if jobGrade and jobGrade > 0 then
        return player.Functions.AddJob(jobName, jobGrade)
    else
        return player.Functions.RemoveJob(jobName)
    end
end

---This will return true if player has the job, false otherwise
---@param source number
---@param jobName string
---@param jobGrade? number
---@return boolean
Framework.PlayerHasJob = function(source, jobName, jobGrade)
    local player = TMC.Functions.GetPlayer(source)
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
    local players = TMC.Functions.GetPlayers()

    for _, src in pairs(players) do
        local player = TMC.Functions.GetPlayer(src)

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
---@param source number (unused)
---@return string | nil
Framework.GetPlayerGroup = function(source)
    return nil
end

---This will return a table of all logged in players
---@return table
Framework.GetAllPlayers = function()
    return TMC.Functions.GetPlayers()
end

---Registers a usable item with a callback function
---@param itemName string Item name
---@param cb function Function to call when item is used
Framework.RegisterUsableItem = function(itemName, cb)
    print('TMC does not have a function to register usable items.')
end

---@param source number (unused)
---@param itemName string (unused)
---@param itemCount number (unused)
---@param metadata? table (unused)
---@param slot? number (unused)
---@return boolean
Framework.AddItem = function(source, itemName, itemCount, metadata, slot)
    return false, print('TMC does not provide a "AddItem" function')
end

---@param source number (unused)
---@param itemName string (unused)
---@param itemCount number (unused)
---@param metadata? table (unused)
---@param slot? number (unused)
---@return boolean
Framework.RemoveItem = function(source, itemName, itemCount, metadata, slot)
    return false, print('TMC does not provide a "RemoveItem" function')
end

---@param source number (unused)
---@param itemName string (unused)
---@param itemCount number (unused)
---@param metadata? table (unused)
---@return boolean
Framework.CanCarryItem = function(source, itemName, itemCount, metadata)
    return false, print('TMC does not provide a "CanCarryItem" function')
end

---@param source number (unused)
---@param items string | string[] (unused)
---@return number
Framework.GetItemCount = function(source, items)
    return 0, print('TMC does not provide a "GetItemCount" function')
end

---@param source number (unused)
---@param items string | string[] (unused)
---@param itemCount number (unused)
---@return boolean
Framework.HasItem = function(source, items, itemCount)
    return false, print('TMC does not provide a "HasItem" function')
end

---@param source number (unused)
---@param itemName string (unused)
---@param metadata? table (unused)
---@param slot? number (unused)
---@return table
Framework.GetItemData = function(source, itemName, metadata, slot)
    return {}, print('TMC does not provide a "GetItemData" function')
end

---@param source number (unused)
---@param itemName string (unused)
---@param metadata? table (unused)
---@param slot? number (unused)
---@return table
Framework.GetItemByName = function(source, itemName, metadata, slot)
    return {}, print('TMC does not provide a "GetItemByName" function')
end

---@param source number (unused)
---@param slot number (unused)
---@return table
Framework.GetItemBySlot = function(source, slot)
    return {}, print('TMC does not provide a "GetItemBySlot" function')
end

---@param source number (unused)
---@return table
Framework.GetPlayerInventory = function(source)
    return {}, print('TMC does not provide a "GetPlayerInventory" function')
end

---@param source number (unused)
Framework.ClearPlayerInventory = function(source)
    print('TMC does not provide a "ClearPlayerInventory" function')
end

---@param source number (unused)
---@param slot number (unused)
---@param metadata table (unused)
Framework.SetMetadata = function(source, slot, metadata)
    return {}, print('TMC does not provide a "SetMetadata" function')
end

---@param itemName string (unused)
---@return string
Framework.GetItemlabel = function(itemName)
    return '', print('TMC does not provide a "GetItemlabel" function')
end

---@param itemName? string (unused)
---@return table
Framework.Items = function(itemName)
    return {}, print('TMC does not provide a "Items" function')
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
RegisterNetEvent('TMC:Server:OnPlayerLoaded', function(src)
    src = src or source
    TriggerEvent('div_bridge/server/OnPlayerLoaded', src)
end)

---Event handler for when player logs out
---@param src number
RegisterNetEvent('TMC:Server:OnPlayerUnLoaded', function(src)
    src = src or source
    TriggerEvent('div_bridge/server/OnPlayerUnload', src)
end)

---Event handler for when a player disconnects from the server
AddEventHandler('playerDropped', function()
    local src = source
    TriggerEvent('div_bridge/server/OnPlayerUnload', src)
end)

return Framework