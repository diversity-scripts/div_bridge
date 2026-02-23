Bridge.loadLib()

local Ox = require '@ox_core/lib/init'

return {
    ---@param source number
    ---@return table | nil
    GetPlayerFromId = function(source)
        return Ox.GetPlayer(tonumber(source)) or nil
    end,

    ---@param identifier string
    ---@return table | nil
    GetPlayerFromIdentifier = function(identifier)
        return Ox.GetPlayerFromCharId(identifier) or nil
    end,

    ---@param source number
    ---@return number | nil
    GetPlayerIdentifier = function(source)
        local player = Ox.GetPlayer(tonumber(source))
        return player?.charId or nil
    end,

    ---@param source number
    ---@return table
    GetPlayerName = function(source)
        local player = Ox.GetPlayer(tonumber(source))
        if not player then return { fullName = '', firstName = '', lastName = '' } end
        return {
            fullName = (player.get('firstName') or '') .. ' ' .. (player.get('lastName') or ''),
            firstName = player.get('firstName') or '',
            lastName = player.get('lastName') or '',
        }
    end,

    ---@return 'male' | 'female' | nil
    GetPlayerGender = function(source)
        local player = Ox.GetPlayer(tonumber(source))   
        return player?.get('gender') or nil
    end,

    ---@param source number
    ---@return table
    GetPlayerJob = function(source)
        local player = Ox.GetPlayer(tonumber(source))
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
    end,

    ---@param source number
    ---@param jobName string
    ---@param jobGrade? number
    ---@return boolean
    PlayerHasJob = function(source, jobName, jobGrade)
        local player = Ox.GetPlayer(tonumber(source))
        if not player then return false end

        local filter = jobGrade and { [jobName] = jobGrade } or jobName
        local hasJob = player.getGroup(filter)

        return hasJob and true or false
    end,

    ---@param jobName string
    ---@return number
    GetJobCount = function(jobName)
        return GlobalState[('%s:count'):format(jobName)] or 0
    end,

    ---@param source number
    ---@param jobName string
    ---@param jobGrade? number
    SetPlayerJob = function(source, jobName, jobGrade)
        local player = Ox.GetPlayer(tonumber(source))
        if not player then return end
        player.setGroup(jobName, jobGrade)
    end,

    ---@return table
    GetAllPlayers = function()
        return Ox.GetPlayers()
    end,

    ---@param itemName string Item name
    ---@param fn function Function to call when item is used
    RegisterUsableItem = function(itemName, fn)
        -- OX Core does not have a function to register usable items
    end,
}