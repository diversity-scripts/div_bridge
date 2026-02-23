return {
    ---@return boolean
    IsPlayerLoaded = function()
        return LocalPlayer.state.isLoggedIn
    end,

    ---@return table
    GetPlayerData = function()
        return exports.qbx_core:GetPlayerData()
    end,

    ---@return table
    GetPlayerName = function()
        local playerData = exports.qbx_core:GetPlayerData()
        if not playerData or not playerData.charinfo then return { fullName = '', firstName = '', lastName = '' } end
        return {
            fullName = (playerData.charinfo.firstname or '') .. ' ' .. (playerData.charinfo.lastname or ''),
            firstName = playerData.charinfo.firstname or '',
            lastName = playerData.charinfo.lastname or '',
        }
    end,

    ---@return 'male' | 'female' | nil
    GetPlayerGender = function()
        local playerData = exports.qbx_core:GetPlayerData()
        return playerData?.charinfo?.gender or nil
    end,

    ---@return table
    GetPlayerJob = function()
        local playerData = exports.qbx_core:GetPlayerData()
        local job = playerData?.job or {}
        return playerData?.job and {
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
        local playerData = exports.qbx_core:GetPlayerData()
        local playerJob = playerData?.job
        return playerJob and playerJob.name == jobName and (not jobGrade or tonumber(playerJob.grade.level) >= jobGrade)
    end,

    ---@return number playerId, number distance
    GetClosestPlayer = function()
        return QBCore.Functions.GetClosestPlayer()
    end,

    ---@return number vehicleId, number distance
    GetClosestVehicle = function()
        return QBCore.Functions.GetClosestVehicle()
    end,

    ---@param msg string
    ---@param _type? 'success' | 'error' | 'info' | 'warning'
    ---@param duration? number
    Notify = function(msg, _type, duration)
        exports.qbx_core:Notify(msg, _type, duration)
    end,
}
