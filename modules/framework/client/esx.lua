local ESX = exports.es_extended:getSharedObject()

return {
    ---@return boolean
    IsPlayerLoaded = function()
        return ESX.IsPlayerLoaded()
    end,

    ---@return table
    GetPlayerData = function()
        return ESX.GetPlayerData()
    end,

    ---@return table
    GetPlayerName = function()
        local playerData = ESX.GetPlayerData()
        if not playerData then return { fullName = '', firstName = '', lastName = '' } end
        return {
            fullName = (playerData.firstName or '') .. ' ' .. (playerData.lastName or ''),
            firstName = playerData.firstName or '',
            lastName = playerData.lastName or '',
        }
    end,

    ---@return 'male' | 'female' | nil
    GetPlayerGender = function()
        local playerData = ESX.GetPlayerData()
        return playerData?.sex and (playerData.sex == 'm' and 'male' or 'female') or nil
    end,

    ---@return table
    GetPlayerJob = function()
        local playerData = ESX.GetPlayerData()
        return playerData?.job and {
            name = playerData.job.name,
            label = playerData.job.label,
            grade = playerData.job.grade,
            gradeLabel = playerData.job.grade_label,
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
        local playerData = ESX.GetPlayerData()
        local playerJob = playerData?.job
        return playerJob and playerJob.name == jobName and (not jobGrade or tonumber(playerJob.grade) >= jobGrade)
    end,

    ---@return number playerId, number distance
    GetClosestPlayer = function()
        return ESX.Game.GetClosestPlayer()
    end,

    ---@return number vehicleId, number distance
    GetClosestVehicle = function()
        return ESX.Game.GetClosestVehicle()
    end,

    ---@param msg string
    ---@param _type? 'success' | 'error' | 'info' | 'warning'
    ---@param duration? number
    Notify = function(msg, _type, duration)
        ESX.ShowNotification(msg, _type, duration)
    end,
}
