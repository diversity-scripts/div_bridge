Bridge.loadLib()

local Ox = require '@ox_core/lib/init'

return {
    ---@return boolean
    IsPlayerLoaded = function()
        local player = Ox.GetPlayer()
        return player and player.charId or false
    end,

    ---@return table
    GetPlayerData = function()
        return Ox.GetPlayer()
    end,

    ---@return table
    GetPlayerName = function()
        local player = Ox.GetPlayer()
        if not player then return { fullName = '', firstName = '', lastName = '' } end
        return {
            fullName = (player.get('firstName') or '') .. ' ' .. (player.get('lastName') or ''),
            firstName = player.get('firstName') or '',
            lastName = player.get('lastName') or '',
        }
    end,

    ---@return 'male' | 'female' | nil
    GetPlayerGender = function()
        local player = Ox.GetPlayer()
        return player?.get('gender') or nil
    end,

    ---@return table
    GetPlayerJob = function()
        local player = Ox.GetPlayer()
        if not player then return { name = '', label = '', grade = 0, gradeLabel = '' } end

        local activeGroup = player?.get('activeGroup')
        local grade = player?.getGroup(activeGroup)
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

    ---@param jobName string
    ---@param jobGrade? number
    ---@return boolean
    PlayerHasJob = function(jobName, jobGrade)
        local player = Ox.GetPlayer()
        if not player then return false end

        local filter = jobGrade and { [jobName] = jobGrade } or jobName
        local hasJob = player.getGroup(filter)

        return hasJob and true or false
    end,

    ---@return number playerId, number distance
    GetClosestPlayer = function()
        local coords = GetEntityCoords(cache.ped)
        local closestPlayer, _, closestCoords = lib.getClosestPlayer(coords, 424, false)
        return closestPlayer, #(coords - closestCoords)
    end,

    ---@return number vehicleId, number distance
    GetClosestVehicle = function()
        local coords = GetEntityCoords(cache.ped)
        local closestVehicle, _, closestCoords = lib.getClosestVehicle(coords, 424, false)
        return closestVehicle, #(coords - closestCoords)
    end,

    ---@param message string
    ---@param type? 'success' | 'error' | 'info' | 'warning'
    ---@param duration? number
    Notify = function(message, type, duration)
        lib.notify({
            description = message,
            type = type or 'info',
            duration = duration or 5000
        })
    end,
}
