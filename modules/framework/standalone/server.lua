local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'standalone'
end

-- [[ Player Related ]] --

---This will get player data from player ID
---@param source number
---@return table | nil
Framework.GetPlayerFromId = function(source)
    return nil, print('Framework does not provide a "GetPlayerFromId" function.')
end

---This will get player data from player identifier
---@param identifier string
---@return table | nil
Framework.GetPlayerFromIdentifier = function(identifier)
    return nil, print('Framework does not provide a "GetPlayerFromIdentifier" function.')
end

---This will get the players identifier (citizenid)
---@param source number
---@return string | nil
Framework.GetPlayerIdentifier = function(source)
    return nil, print('Framework does not provide a "GetPlayerIdentifier" function.')
end

---This will get the players name
---@param source number
---@return table {fullName, firstName, lastName}
Framework.GetPlayerName = function(source)
    return {}, print('Framework does not provide a "GetPlayerName" function.')
end

---This will get the players gender
---@param source number
---@return 'male' | 'female' | nil
Framework.GetPlayerGender = function(source)
    return nil, print('Framework does not provide a "GetPlayerGender" function.')
end

---This will get the players birth date
---@param source number
---@return string
Framework.GetPlayerDob = function(source)
    return '', print('Framework does not provide a "GetPlayerDob" function.')
end

---This will return the players job
---@param source number
---@return table {name, label, grade, gradeLabel}
Framework.GetPlayerJob = function(source)
    return {
        name = '',
        label = '',
        grade = 0,
        gradeLabel = '',
    }, print('Framework does not provide a "GetPlayerJob" function.')
end

---This will set the players job
---@param source number
---@param jobName string
---@param jobGrade? number
---@return boolean
Framework.SetPlayerJob = function(source, jobName, jobGrade)
    return false, print('Framework does not provide a "SetPlayerJob" function.')
end

---This will return true if player has the job, false otherwise
---@param source number
---@param jobName string
---@param jobGrade? number
---@return boolean
Framework.PlayerHasJob = function(source, jobName, jobGrade)
    return false, print('Framework does not provide a "PlayerHasJob" function.')
end

---This will return a number of all players with a specified job
---@param jobName string
---@return number
Framework.GetJobCount = function(jobName)
    return 0, print('Framework does not provide a "GetJobCount" function.')
end

---This will return the players group
---@param source number
---@return string | nil
Framework.GetPlayerGroup = function(source)
    return nil, print('Framework does not provide a "GetPlayerGroup" function.')
end

---This will return a table of all logged in players
---@return table
Framework.GetAllPlayers = function()
    return GetActivePlayers() or {}
end

---This will return the jobs registered in the framework
---@return table {name = jobName, label = jobLabel, grade = {name = gradeName, level = gradeLevel}}
Framework.GetFrameworkJobs = function()
    return {name = '', label = '', grade = {name = '', level = 0}}, print('Framework does not provide a "GetFrameworkJobs" function.')
end

-- [[ Inventory Related ]] --

---Registers a usable item with a callback function
---@param itemName string Item name
---@param cb function Function to call when item is used
Framework.RegisterUsableItem = function(itemName, cb)
    print('Framework does not provide a "RegisterUsableItem" function.')
end

---@param source number
---@param itemName string
---@param itemCount number
---@param metadata? table
---@param slot? number
---@return boolean
Framework.AddItem = function(source, itemName, itemCount, metadata, slot)
    return false, print('Framework does not provide a "AddItem" function.')
end

---@param source number
---@param itemName string
---@param itemCount number
---@param metadata? table
---@param slot? number
---@return boolean
Framework.RemoveItem = function(source, itemName, itemCount, metadata, slot)
    return false, print('Framework does not provide a "RemoveItem" function.')
end

---@param source number
---@param itemName string
---@param itemCount number
---@param metadata? table
---@return boolean
Framework.CanCarryItem = function(source, itemName, itemCount, metadata)
    return false, print('Framework does not provide a "CanCarryItem" function.')
end

---@param source number
---@param items string | string[]
---@return number
Framework.GetItemCount = function(source, items)
    return 0, print('Framework does not provide a "GetItemCount" function.')
end

---@param source number
---@param items string | string[]
---@param itemCount number
---@return boolean
Framework.HasItem = function(source, items, itemCount)
    return false, print('Framework does not provide a "HasItem" function.')
end

---@param source number
---@param itemName string
---@param metadata? table
---@param slot? number
---@return table
Framework.GetItemData = function(source, itemName, metadata, slot)
    return {}, print('Framework does not provide a "GetItemData" function.')
end

---@param source number
---@param itemName string
---@param metadata? table
---@param slot? number
---@return table
Framework.GetItemByName = function(source, itemName, metadata, slot)
    return {}, print('Framework does not provide a "GetItemByName" function.')
end

---@param source number
---@param slot number
---@return table
Framework.GetItemBySlot = function(source, slot)
    return {}, print('Framework does not provide a "GetItemBySlot" function')
end

---@param source number
---@return table
Framework.GetPlayerInventory = function(source)
    return {}, print('Framework does not provide a "GetPlayerInventory" function.')
end

---@param source number
Framework.ClearPlayerInventory = function(source)
    print('Framework does not provide a "ClearPlayerInventory" function.')
end

---@param source number
---@param slot number
---@param metadata table
Framework.SetMetadata = function(source, slot, metadata)
    return {}, print('Framework does not support metadata')
end

---@param itemName string
---@return string
Framework.GetItemlabel = function(itemName)
    return '', print('Framework does not provide a "GetItemlabel" function.')
end

---@param itemName? string
---@return table
Framework.Items = function(itemName)
    return {}, print('Framework does not have a way to retrieve items.')
end

-- [[ Account Related ]] --

---This will return the players money by account type
---@param source number
---@param accountType 'money' | 'bank'
---@return number
Framework.GetPlayerAccountBalance = function(source, accountType)
    return 0, print('Framework does not provide a "GetPlayerAccountBalance" function.')
end

---This will add money to the player by account type
---@param source number
---@param accountType 'money' | 'bank'
---@param amount number
---@return boolean
Framework.AddPlayerAccountBalance = function(source, accountType, amount)
    return false, print('Framework does not provide a "AddPlayerAccountBalance" function.')
end

---This will remove the players money by account type
---@param source number
---@param accountType 'money' | 'bank'
---@param amount number
---@return boolean
Framework.RemovePlayerAccountBalance = function(source, accountType, amount)
    return false, print('Framework does not provide a "RemovePlayerAccountBalance" function.')
end

---This will return the job account money by account type
---@param accountId string | number
---@return number
Framework.GetJobAccountBalance = function(accountId)
    return 0, print('ESX does not provide a "GetJobAccountBalance" function')
end

---This will add money to the job account by account type
---@param accountId string | number
---@param amount number
---@param reason? string
---@return boolean
Framework.AddJobAccountBalance = function(accountId, amount, reason)
    return false, print('ESX does not provide a "AddJobAccountBalance" function')
end

---This will remove the job account money by account type
---@param accountId string | number
---@param amount number
---@param reason? string
---@return boolean
Framework.RemoveJobAccountBalance = function(accountId, amount, reason)
    return false, print('ESX does not provide a "RemoveJobAccountBalance" function')
end

-- [[ Event Related ]] --

---Event handler for when player logs out
AddEventHandler('playerDropped', function()
    local src = source
    TriggerEvent('div_bridge:server:OnPlayerUnloaded', src)
end)

return Framework
