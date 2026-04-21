Bridge.loadOxLib()
local Ox = require '@ox_core/lib/init'
local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'ox_core'
end

-- [[ Player Related ]] --

---This will get player data from player ID
---@param source number
---@return table | nil
Framework.GetPlayerFromId = function(source)
    return Ox.GetPlayer(tonumber(source)) or nil
end

---This will get player data from player identifier
---@param identifier string
---@return table | nil
Framework.GetPlayerFromIdentifier = function(identifier)
    return Ox.GetPlayerFromCharId(identifier) or nil
end

---This will get the players identifier (citizenid)
---@param source number
---@return number | nil
Framework.GetPlayerIdentifier = function(source)
    local player = Framework.GetPlayerFromId(source)
    return player?.charId or nil
end

---This will get the players name
---@param source number
---@return table {fullName, firstName, lastName}
Framework.GetPlayerName = function(source)
    local player = Framework.GetPlayerFromId(source)
    if not player then return { fullName = '', firstName = '', lastName = '' } end
    return {
        fullName = (player.get('firstName') or '') .. ' ' .. (player.get('lastName') or ''),
        firstName = player.get('firstName') or '',
        lastName = player.get('lastName') or '',
    }
end

---This will get the players gender
---@param source number
---@return 'male' | 'female' | nil
Framework.GetPlayerGender = function(source)
    local player = Framework.GetPlayerFromId(source)
    return player?.get('gender') or nil
end

---This will get the players birth date
---@param source number
---@return string
Framework.GetPlayerDob = function(source)
    local player = Framework.GetPlayerFromId(source)
    return player?.get('dateOfBirth') or ''
end

---This will return the players job
---@param source number
---@return table {name, label, grade, gradeLabel}
Framework.GetPlayerJob = function(source)
    local player = Framework.GetPlayerFromId(source)
    if not player then return { name = '', label = '', grade = 0, gradeLabel = '' } end

    local activeGroup = player.get('activeGroup')
    local grade = player.getGroup(activeGroup)
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

---This will set the players job
---@param source number
---@param jobName string
---@param jobGrade? number
---@return boolean
Framework.SetPlayerJob = function(source, jobName, jobGrade)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end
    return player.setGroup(jobName, jobGrade)
end

---This will return true if player has the job, false otherwise
---@param source number
---@param jobName string
---@param jobGrade? number
---@return boolean
Framework.PlayerHasJob = function(source, jobName, jobGrade)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end

    local filter = jobGrade and { [jobName] = jobGrade } or jobName
    local hasJob = player.getGroup(filter)

    return hasJob and true or false
end

---This will return a number of all players with a specified job
---@param jobName string
---@return number
Framework.GetJobCount = function(jobName)
    return GlobalState[('%s:count'):format(jobName)] or 0
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
    return Ox.GetPlayers()
end

---This will return the jobs registered in the framework
---@return table
Framework.GetFrameworkJobs = function()
    return QBCore.Shared.Jobs
end

-- [[ Inventory Related ]] --

---@param itemName string Item name (unused)
---@param cb function Function to call when item is used (unused)
Framework.RegisterUsableItem = function(itemName, cb)
    print('ox_core does not have a function to register usable items.')
end

---@param source number (unused)
---@param itemName string (unused)
---@param itemCount number (unused)
---@param metadata? table (unused)
---@param slot? number (unused)
---@return boolean
Framework.AddItem = function(source, itemName, itemCount, metadata, slot)
    return false, print('ox_core does not provide a "AddItem" function')
end

---@param source number (unused)
---@param itemName string (unused)
---@param itemCount number (unused)
---@param metadata? table (unused)
---@param slot? number (unused)
---@return boolean
Framework.RemoveItem = function(source, itemName, itemCount, metadata, slot)
    return false, print('ox_core does not provide a "RemoveItem" function')
end

---@param source number (unused)
---@param itemName string (unused)
---@param itemCount number (unused)
---@param metadata? table (unused)
---@return boolean
Framework.CanCarryItem = function(source, itemName, itemCount, metadata)
    return false, print('ox_core does not provide a "CanCarryItem" function')
end

---@param source number (unused)
---@param items string | string[] (unused)
---@return number
Framework.GetItemCount = function(source, items)
    return 0, print('ox_core does not provide a "GetItemCount" function')
end

---@param source number (unused)
---@param items string | string[] (unused)
---@param itemCount number (unused)
---@return boolean
Framework.HasItem = function(source, items, itemCount)
    return false, print('ox_core does not provide a "HasItem" function')
end

---@param source number (unused)
---@param itemName string (unused)
---@param metadata? table (unused)
---@param slot? number (unused)
---@return table
Framework.GetItemData = function(source, itemName, metadata, slot)
    return {}, print('ox_core does not provide a "GetItemData" function')
end

---@param source number (unused)
---@param itemName string (unused)
---@param metadata? table (unused)
---@param slot? number (unused)
---@return table
Framework.GetItemByName = function(source, itemName, metadata, slot)
    return {}, print('ox_core does not provide a "GetItemByName" function')
end

---@param source number (unused)
---@param slot number (unused)
---@return table
Framework.GetItemBySlot = function(source, slot)
    return {}, print('ox_core does not provide a "GetItemBySlot" function')
end

---@param source number (unused)
---@return table
Framework.GetPlayerInventory = function(source)
    return {}, print('ox_core does not provide a "GetPlayerInventory" function')
end

---@param source number (unused)
Framework.ClearPlayerInventory = function(source)
    print('ox_core does not provide a "ClearPlayerInventory" function')
end

---@param source number (unused)
---@param slot number (unused)
---@param metadata table (unused)
Framework.SetMetadata = function(source, slot, metadata)
    return {}, print('ox_core does not provide a "SetMetadata" function')
end

---@param itemName string (unused)
---@return string
Framework.GetItemlabel = function(itemName)
    return '', print('ox_core does not provide a "GetItemlabel" function')
end

---@param itemName? string (unused)
---@return table
Framework.Items = function(itemName)
    return {}, print('ox_core does not provide a "Items" function')
end

-- [[ Account Related ]] --

---This will return the players money by account type
---@param source number
---@param accountType 'bank'
---@return number
Framework.GetAccountBalance = function(source, accountType)
    local player = Framework.GetPlayerFromId(source)
    if not player then return 0 end

    if accountType == 'money' or accountType == 'cash' then
        return 0, print('ox_core does not support "cash" accounts.')
    end

    local account = Ox.GetCharacterAccount(player.charId)
    return account?.balance or 0
end

---This will add money to the player by account type
---@param source number
---@param accountType 'cash' | 'bank'
---@param amount number
---@return boolean
Framework.AddAccountBalance = function(source, accountType, amount)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end

    if amount <= 0 then return false end
    if accountType == 'money' or accountType == 'cash' then
        return false, print('ox_core does not support "cash" accounts.')
    end

    local account = Ox.GetCharacterAccount(player.charId)
    local retval = account?.addBalance({ amount = amount }) or nil

    return retval?.success or false
end

---This will remove the players money by account type
---@param source number
---@param accountType 'cash' | 'bank'
---@param amount number
---@return boolean
Framework.RemoveAccountBalance = function(source, accountType, amount)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end

    if amount <= 0 then return false end
    if accountType == 'money' or accountType == 'cash' then
        return false, print('ox_core does not support "cash" accounts.')
    end

    local account = Ox.GetCharacterAccount(player.charId)
    local retval = account?.removeBalance({ amount = amount, overdraw = false }) or nil

    return retval?.success or false
end

---This will return the job account money by account type
---@param accountId string | number
---@return number
Framework.GetJobAccountBalance = function(accountId)
    local account = Ox.GetGroupAccount(accountId)
    return account?.balance or 0
end

---This will add money to the job account by account type
---@param accountId string | number
---@param amount number
---@param reason? string
---@return boolean
Framework.AddJobAccountBalance = function(accountId, amount, reason)
    local account = Ox.GetGroupAccount(accountId)
    local retval = account?.addBalance({ amount = amount, message = reason or nil }) or nil
    return retval?.success or false
end

---This will remove the job account money by account type
---@param accountId string | number
---@param amount number
---@param reason? string
---@return boolean
Framework.RemoveJobAccountBalance = function(accountId, amount, reason)
    local account = Ox.GetGroupAccount(accountId)
    local retval = account?.removeBalance({ amount = amount, message = reason or nil, overdraw = false }) or nil
    return retval?.success or false
end

-- [[ Event Related ]] --

---Event handler for when player is loaded in
---@param playerId number
RegisterNetEvent('ox:playerLoaded', function(playerId)
    src = playerId or source
    TriggerEvent('div_bridge:server:OnPlayerLoaded', playerId)
end)

---Event handler for when player logs out
---@param playerId number
RegisterNetEvent('ox:playerLogout', function(playerId)
    src = playerId or source
    TriggerEvent('div_bridge:server:OnPlayerUnloaded', playerId)
end)

---Event handler for when player job is updated
---@param playerId number
---@param groupName string
---@param grade? number
RegisterNetEvent('ox:setGroup', function(playerId, groupName, grade)
    src = playerId or source
    local data = GlobalState[('group.%s'):format(groupName)]
    local label = data?.label or 'N/A'
    local gradeLabel = grade and data?.grades[grade]?.label or 0
    TriggerEvent('div_bridge:server:OnPlayerJobChange', { playerId = playerId, name = groupName, label = label, grade = grade or 0, gradeLabel = gradeLabel })
end)

return Framework
