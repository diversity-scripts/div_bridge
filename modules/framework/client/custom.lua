return {
    ---@return boolean
    IsPlayerLoaded = function()
        return true
    end,

    ---@return table
    GetPlayerData = function()
        return {}
    end,

    ---@return table
    GetPlayerName = function()
        return {
            fullName = '',
            firstName = '',
            lastName = '',
        }
    end,

    ---@return 'male' | 'female' | nil
    GetPlayerGender = function()
        return 'male'
    end,

    ---@return table
    GetPlayerJob = function()
        return {
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
        return true
    end,

    ---@return number playerId, number distance
    GetClosestPlayer = function()
        return 0, 0
    end,

    ---@return number vehicleId, number distance
    GetClosestVehicle = function()
        return 0, 0
    end,

    ---@param msg string
    ---@param _type? 'success' | 'error' | 'info' | 'warning'
    ---@param duration? number
    Notify = function(msg, _type, duration)
        -- Add custom notification logic here
        print(('[Notify] %s (%s) - %dms'):format(msg, _type, duration or 5000))
    end,
}
