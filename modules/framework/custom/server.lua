local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'custom'
end

-- [[ Player Related ]] --

---This will get player data from player ID
---@param source number
---@return table | nil
Framework.GetPlayerFromId = function(source)
    return {}
end

---This will get player data from player identifier
---@param identifier string
---@return table | nil
Framework.GetPlayerFromIdentifier = function(identifier)
    return {}
end

---This will get the players identifier (citizenid)
---@param source number
---@return number | nil
Framework.GetPlayerIdentifier = function(source)
    return nil
end

---This will get the players name
---@param source number
---@return table {fullName, firstName, lastName}
Framework.GetPlayerName = function(source)
    return {
        fullName ='',
        firstName = '',
        lastName = '',
    }
end

---This will get the players gender
---@param source number
---@return 'male' | 'female' | nil
Framework.GetPlayerGender = function(source)
    return 'male'
end

---This will get the players birth date
---@param source number
---@return string
Framework.GetPlayerDob = function(source)
    return ''
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
    }
end

---This will set the players job
---@param source number
---@param jobName string
---@param jobGrade? number
---@return boolean
Framework.SetPlayerJob = function(source, jobName, jobGrade)
    return true
end

---This will return true if player has the job, false otherwise
---@param source number
---@param jobName string
---@param jobGrade? number
---@return boolean
Framework.PlayerHasJob = function(source, jobName, jobGrade)
    return true
end

---This will return a number of all players with a specified job
---@param jobName string
---@return number
Framework.GetJobCount = function(jobName)
    return 0
end

---This will return a table of all logged in players
---@return table
Framework.GetAllPlayers = function()
    return {}
end

---@param itemName string Item name
---@param cb function Function to call when item is used
Framework.RegisterUsableItem = function(itemName, cb)

end

---@param source number (unused)
---@param itemName string (unused)
---@param itemCount number (unused)
---@param metadata? table (unused)
---@param slot? number (unused)
---@return boolean
Framework.AddItem = function(source, itemName, itemCount, metadata, slot)
    return false
end

---@param source number (unused)
---@param itemName string (unused)
---@param itemCount number (unused)
---@param metadata? table (unused)
---@param slot? number (unused)
---@return boolean
Framework.RemoveItem = function(source, itemName, itemCount, metadata, slot)
    return false
end

---@param source number (unused)
---@param itemName string (unused)
---@param itemCount number (unused)
---@param metadata? table (unused)
---@return boolean
Framework.CanCarryItem = function(source, itemName, itemCount, metadata)
    return false
end

---@param source number (unused)
---@param items string | string[] (unused)
---@return number
Framework.GetItemCount = function(source, items)
    return 0
end

---@param source number (unused)
---@param items string | string[] (unused)
---@param itemCount number (unused)
---@return boolean
Framework.HasItem = function(source, items, itemCount)
    return false
end

---@param source number (unused)
---@param itemName string (unused)
---@param metadata? table (unused)
---@param slot? number (unused)
---@return table
Framework.GetItemData = function(source, itemName, metadata, slot)
    return {}
end

---@param source number (unused)
---@param itemName string (unused)
---@param metadata? table (unused)
---@param slot? number (unused)
---@return table
Framework.GetItemByName = function(source, itemName, metadata, slot)
    return {}
end

---@param source number (unused)
---@param slot number (unused)
---@return table
Framework.GetItemBySlot = function(source, slot)
    return {}
end

---@param source number (unused)
---@return table
Framework.GetPlayerInventory = function(source)
    return {}
end

---@param source number (unused)
Framework.ClearPlayerInventory = function(source)

end

---@param source number (unused)
---@param slot number (unused)
---@param metadata table (unused)
Framework.SetMetadata = function(source, slot, metadata)
    return {}
end

---@param itemName string (unused)
---@return string
Framework.GetItemlabel = function(itemName)
    return ''
end

---@param itemName? string (unused)
---@return table
Framework.Items = function(itemName)
    return {}
end

-- [[ Account Related ]] --

---This will add money to the player by account type
---@param source number
---@param accountType 'cash' | 'bank'
---@param amount number
---@return boolean
Framework.AddAccountBalance = function(source, accountType, amount)
    return false
end

---This will remove the players money by account type
---@param source number
---@param accountType 'cash' | 'bank'
---@param amount number
---@return boolean
Framework.RemoveAccountBalance = function(source, accountType, amount)
    return false
end

---This will return the players money by account type
---@param source number
---@param accountType 'bank'
---@return number
Framework.GetAccountBalance = function(source, accountType)
    return 0
end

-- [[ Event Related ]] --

---Event handler for when a player disconnects from the server
AddEventHandler('playerDropped', function()
    local src = source
    TriggerEvent('div_bridge/server/OnPlayerUnload', src)
end)

return Framework