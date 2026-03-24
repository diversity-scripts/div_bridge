local ESX = exports.es_extended:getSharedObject()
local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'es_extended'
end

-- [[ Player Related ]] --

---This will get player data from player ID
---@param source number
---@return table | nil
Framework.GetPlayerFromId = function(source)
    return ESX.GetPlayerFromId(tonumber(source)) or nil
end

---This will get player data from player identifier
---@param identifier string
---@return table | nil
Framework.GetPlayerFromIdentifier = function(identifier)
    return ESX.GetPlayerFromIdentifier(identifier) or nil
end

---This will get the players identifier (citizenid)
---@param source number
---@return string | nil
Framework.GetPlayerIdentifier = function(source)
    local player = Framework.GetPlayerFromId(source)
    return player?.getIdentifier() or nil
end

---This will get the players name
---@param source number
---@return table {fullName, firstName, lastName}
Framework.GetPlayerName = function(source)
    local player = Framework.GetPlayerFromId(source)
    if not player then return { fullName = '', firstName = '', lastName = '' } end
    return {
        fullName = player.getName() or '',
        firstName = player.get('firstName') or '',
        lastName = player.get('lastName') or '',
    }
end

---This will get the players gender
---@param source number
---@return 'male' | 'female' | nil
Framework.GetPlayerGender = function(source)
    local player = Framework.GetPlayerFromId(source)
    return player and (player.get('sex') == 'm' and 'male' or 'female') or nil
end

---This will get the players birth date
---@param source number
---@return string
Framework.GetPlayerDob = function(source)
    local player = Framework.GetPlayerFromId(source)
    return player?.get('dateofbirth') or ''
end

---This will return the players job
---@param source number
---@return table {name, label, grade, gradeLabel}
Framework.GetPlayerJob = function(source)
    local player = Framework.GetPlayerFromId(source)
    if not player then return { name = '', label = '', grade = 0, gradeLabel = '' } end

    local currentJob = player.getJob()
    if not currentJob then return { name = '', label = '', grade = 0, gradeLabel = '' } end

    return {
        name = currentJob.name or '',
        label = currentJob.label or '',
        grade = currentJob.grade or 0,
        gradeLabel = currentJob.grade_label or '',
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
    if not ESX.DoesJobExist(jobName, jobGrade) then
        print(('Job does not exist in framework! (Name: %s Grade: %s)'):format(jobName, jobGrade))
        return false
    end
    player.setJob(jobName, jobGrade or 0)
    return true
end

---This will return true if player has the job, false otherwise
---@param source number
---@param jobName string
---@param jobGrade? number
---@return boolean
Framework.PlayerHasJob = function(source, jobName, jobGrade)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end

    local currentJob = player.getJob()
    if not currentJob then return false end

    return currentJob and currentJob.name == jobName and (not jobGrade or tonumber(currentJob.grade) >= jobGrade)
end

---This will return a number of all players with a specified job
---@param jobName string
---@return number
Framework.GetJobCount = function(jobName)
    local xPlayers = ESX.GetExtendedPlayers('job', jobName)
    return #xPlayers
end

---This will return the players group
---@param source number
---@return string | nil
Framework.GetPlayerGroup = function(source)
    local player = Framework.GetPlayerFromId(source)
    return player?.getGroup() or nil
end

---This will return a table of all logged in players
---@return table
Framework.GetAllPlayers = function()
    return ESX.GetExtendedPlayers()
end

---This will return the jobs registered in the framework
---@return table {name = jobName, label = jobLabel, grade = {name = gradeName, level = gradeLevel}}
Framework.GetFrameworkJobs = function()
    return ESX.GetJobs()
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
    ESX.RegisterUsableItem(itemName, func)
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
    player.addInventoryItem(itemName, itemCount or 1)
    return true
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
    local current = player.getInventoryItem(itemName)
    if not current or (current.count or 0) < (itemCount or 1) then return false end
    player.removeInventoryItem(itemName, itemCount or 1)
    return true
end

---@param source number
---@param itemName string
---@param itemCount number
---@param metadata? table
---@return boolean
Framework.CanCarryItem = function(source, itemName, itemCount, metadata)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end
    if player.canCarryItem then
        return player.canCarryItem(itemName, itemCount or 1)
    end
    return true
end

---@param source number
---@param items string | string[]
---@return number
Framework.GetItemCount = function(source, items)
    local player = Framework.GetPlayerFromId(source)
    if not player then return 0 end
    local names = type(items) == 'table' and items or { items }
    local total = 0
    for _, name in pairs(names) do
        local itm = player.getInventoryItem(name)
        total = total + (itm?.count or 0)
    end
    return total
end

---@param source number
---@param items string | string[]
---@param itemCount number
---@return boolean
Framework.HasItem = function(source, items, itemCount)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end
    local names = type(items) == 'table' and items or { items }
    local required = itemCount or 1
    for _, name in pairs(names) do
        local itm = player.getInventoryItem(name)
        if (itm?.count or 0) < required then
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
    return player.getInventoryItem(itemName) or {}
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
    return {}, print('ESX does not provide a "GetItemBySlot" function')
end

---@param source number
---@return table
Framework.GetPlayerInventory = function(source)
    local player = Framework.GetPlayerFromId(source)
    if not player then return {} end
    local repack = {}
    local inv = player.getInventory() or player.get('inventory') or {}
    for _, v in pairs(inv) do
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

---@param source number
Framework.ClearPlayerInventory = function(source)
    local player = Framework.GetPlayerFromId(source)
    if not player then return end
    local inv = player.getInventory() or player.get('inventory') or {}
    for _, v in pairs(inv) do
        if v.count and v.count > 0 then
            player.removeInventoryItem(v.name, v.count)
        end
    end
end

---@param source number
---@param slot number
---@param metadata table
Framework.SetMetadata = function(source, slot, metadata)
    return {}, print('ESX does not support metadata')
end

---@param itemName string
---@return string
Framework.GetItemlabel = function(itemName)
    local item = ESX.GetItem and ESX.GetItem(itemName) or nil
    return item and item.label or itemName
end

---@param itemName? string
---@return table
Framework.Items = function(itemName)
    local items = ESX.GetItems and ESX.GetItems() or nil
    return items or {}
end

-- [[ Account Related ]] --

---This will add money to the player by account type
---@param source number
---@param accountType 'money' | 'bank'
---@param amount number
---@return boolean
Framework.AddAccountBalance = function(source, accountType, amount)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end

    if amount <= 0 then return false end
    if accountType == 'cash' then accountType = 'money' end

    player.addAccountMoney(accountType, amount)
    return true
end

---This will remove the players money by account type
---@param source number
---@param accountType 'money' | 'bank'
---@param amount number
---@return boolean
Framework.RemoveAccountBalance = function(source, accountType, amount)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end

    if amount <= 0 then return false end
    if accountType == 'cash' then accountType = 'money' end

    local balance = Framework.GetAccountBalance(source, accountType)
    if balance < amount then return false end

    player.removeAccountMoney(accountType, amount)
    return true
end

---This will return the players money by account type
---@param source number
---@param accountType 'money' | 'bank'
---@return number
Framework.GetAccountBalance = function(source, accountType)
    local player = Framework.GetPlayerFromId(source)
    if not player then return 0 end

    if accountType == 'cash' then accountType = 'money' end
    local balance = Framework.GetAccountBalance(source, accountType)
    return balance
end

-- [[ Event Related ]] --

---Event handler for when player is loaded in
---@param src number
RegisterNetEvent('esx:playerLoaded', function(src)
    src = src or source
    TriggerEvent('div_bridge/server/OnPlayerLoaded', src)
end)

---Event handler for when player logs out
---@param src number
RegisterNetEvent('esx:playerLogout', function(src)
    src = src or source
    TriggerEvent('div_bridge/server/OnPlayerUnload', src)
end)

---Event handler for when player job is updated
---@param src number
---@param job table
---@param lastJob table
RegisterNetEvent('esx:setJob', function(src, job, lastJob)
    src = src or source
    if not job or not lastJob then return end
    TriggerEvent('div_bridge/server/OnPlayerJobChange', src, job.name)
end)

---Event handler for when a player disconnects from the server
AddEventHandler('playerDropped', function()
    local src = source
    TriggerEvent('div_bridge/server/OnPlayerUnload', src)
end)

return Framework
