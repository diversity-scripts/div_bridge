Bridge.loadOxLib()
local NDCore = exports['ND_Core']
local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'nd_core'
end

-- [[ Player Related ]] --

---This will get player data from player ID
---@param source number
---@return table | nil
Framework.GetPlayerFromId = function(source)
    return NDCore:getPlayer(tonumber(source)) or nil
end

---This will get player data from player identifier
---@param identifier string
---@return table | nil
Framework.GetPlayerFromIdentifier = function(identifier)
    local players = NDCore:getPlayers()
    for _, player in pairs(players) do
        if player.identifier == identifier then
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
    return player?.identifier or nil
end

---This will get the players name
---@param source number
---@return table {fullName, firstName, lastName}
Framework.GetPlayerName = function(source)
    local player = Framework.GetPlayerFromId(source)
    if not player then return { fullName = '', firstName = '', lastName = '' } end
    return {
        fullName = player.fullname,
        firstName = player.firstname or '',
        lastName = player.lastname or '',
    }
end

---This will get the players gender
---@param source number
---@return 'male' | 'female' | nil
Framework.GetPlayerGender = function(source)
    local player = Framework.GetPlayerFromId(source)
    return player?.gender or nil
end

---This will get the players birth date
---@param source number
---@return string
Framework.GetPlayerDob = function(source)
    local player = Framework.GetPlayerFromId(source)
    return player?.birthdate or ''
end

---This will return the players job
---@param source number
---@return table {name, label, grade, gradeLabel}
Framework.GetPlayerJob = function(source)
    local player = Framework.GetPlayerFromId(source)
    if not player then return { name = '', label = '', grade = 0, gradeLabel = '' } end

    local job = player?.job or nil
    local jobInfo = player?.jobInfo or nil
    local grade = jobInfo?.grade or nil

    return job and {
        name = job or '',
        label = jobInfo?.label or '',
        grade = grade or 0,
        gradeLabel = jobInfo?.rankName or '',
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
    return player.setJob(jobName, jobGrade)
end

---This will return true if player has the job, false otherwise
---@param source number
---@param jobName string
---@param jobGrade? number
---@return boolean
Framework.PlayerHasJob = function(source, jobName, jobGrade)
    local player = Framework.GetPlayerFromId(source)
    if not player then return false end

    local job = player.job or {}
    local jobInfo = player.jobInfo or {}

    return job == jobName and (not jobGrade or jobInfo.rank >= jobGrade)
end

---This will return a number of all players with a specified job
---@param jobName string
---@return number
Framework.GetJobCount = function(jobName)
    local count = 0
    local players = NDCore:getPlayers('job', jobName, false)

    for _, playerData in pairs(players) do
        if playerData then
            local job = playerData.job or {}

            if job and job == jobName then
                count = count + 1
            end
        end
    end

    return count
end

---This will return a table of all logged in players
---@return table
Framework.GetAllPlayers = function()
    return NDCore:getPlayers()
end

---@param itemName string Item name
---@param fn function Function to call when item is used
Framework.RegisterUsableItem = function(itemName, fn)
    print('nd_core does not have a function to register usable items.')
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
---@param character table Player data
AddEventHandler('ND:characterLoaded', function(character)
    local src = character.source or source
    TriggerEvent('div_bridge/server/OnPlayerLoaded', src)
end)

---Event handler for when player logs out
---@param src number
AddEventHandler('ND:characterUnloaded', function(src)
    src = src or source
    TriggerEvent('div_bridge/server/OnPlayerUnload', src)
end)

---Event handler for when player job is updated
---@param character table Player data
RegisterNetEvent('ND:updateCharacter', function(character)
    local src = character.source or source
    if not character.job then return end
    TriggerEvent('div_bridge/server/OnPlayerJobChange', src, character.job)
end)

---Event handler for when a player disconnects from the server
AddEventHandler('playerDropped', function()
    local src = source
    TriggerEvent('div_bridge/server/OnPlayerUnload', src)
end)

return Framework