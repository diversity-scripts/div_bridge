Bridge.loadLib()

local NDCore = exports['ND_Core']

return {
    ---@return boolean
    IsPlayerLoaded = function()
        local player = NDCore:getPlayer()
        return player and player.identifier or false
    end,

    ---@return table
    GetPlayerData = function()
        return NDCore:getPlayer()
    end,

    ---@return table
    GetPlayerName = function()
        local player = NDCore:getPlayer()
        if not player then return { fullName = '', firstName = '', lastName = '' } end
        return {
            fullName = player.fullname,
            firstName = player.firstname or '',
            lastName = player.lastname or '',
        }
    end,

    ---@return 'male' | 'female' | nil
    GetPlayerGender = function()
        local player = NDCore:getPlayer()
        return player?.gender or nil
    end,

    ---@return table
    GetPlayerJob = function()
        local player = NDCore:getPlayer()
        if not player then return { name = '', label = '', grade = 0, gradeLabel = '' } end

        local job = player?.job or nil
        local jobInfo = player?.jobInfo or nil
        local grade = jobInfo?.grade or nil

        return job and {
            name = job,
            label = jobInfo?.label or '',
            grade = grade or 0,
            gradeLabel = jobInfo?.rankName or '',
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
        local player = NDCore:getPlayer()
        if not player then return false end
        
        local job = player.job or {}
        local jobInfo = player.jobInfo or {}

        return job == jobName and (not jobGrade or jobInfo.rank >= jobGrade)
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
        NDCore:notify({
            description = message,
            type = type or 'info',
            duration = duration or 5000
        })
    end,
}
