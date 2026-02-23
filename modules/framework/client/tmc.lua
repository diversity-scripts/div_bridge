local TMC = exports.core:getCoreObject()

return {
    ---@return boolean
    IsPlayerLoaded = function()
        return TMC.Functions.IsPlayerLoaded()
    end,

    ---@return table
    GetPlayerData = function()
        return TMC.Functions.GetPlayerData()
    end,

    ---@return table
    GetPlayerName = function()
        local playerData = TMC.Functions.GetPlayerData()
        if not playerData or not playerData.charinfo then return { fullName = '', firstName = '', lastName = '' } end
        return {
            fullName = (playerData.charinfo.firstname or '') .. ' ' .. (playerData.charinfo.lastname or ''),
            firstName = playerData.charinfo.firstname or '',
            lastName = playerData.charinfo.lastname or '',
        }
    end,

    ---@return 'male' | 'female' | nil
    GetPlayerGender = function()
        local playerData = TMC.Functions.GetPlayerData()
        return playerData?.charinfo?.gender and (playerData.charinfo.gender == 'M' and 'male' or 'female') or nil
    end,

    ---@return table
    GetPlayerJob = function()
        local playerData = TMC.Functions.GetPlayerData()
        local job = playerData?.jobs[1] or {}
        return job and {
            name = job.name,
            label = job.label,
            grade = job.grade.level,
            gradeLabel = job.grade.name,
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
        local hasJob = TMC.Functions.HasJob(jobName, jobGrade)
        return hasJob or false
    end,

    ---@return number playerId, number distance
    GetClosestPlayer = function()
        return TMC.Functions.GetClosestPlayer()
    end,

    ---@return number vehicleId, number distance
    GetClosestVehicle = function()
        return TMC.Functions.GetClosestVehicle()
    end,

    ---@param msg string
    ---@param _type? 'success' | 'error' | 'info' | 'warning'
    ---@param duration? number
    Notify = function(msg, _type, duration)
        TMC.Functions.SimpleNotify(msg, _type or 'info', duration or 5000)
    end,
}
