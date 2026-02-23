return {
    ---@param source number
    ---@return table | nil
    GetPlayerFromId = function(source)
        return exports.qbx_core:GetPlayer(tonumber(source)) or nil
    end,

    ---@param identifier string
    ---@return table | nil
    GetPlayerFromIdentifier = function(identifier)
        return exports.qbx_core:GetPlayerByCitizenId(identifier) or nil
    end,

    ---@param source number
    ---@return string | nil
    GetPlayerIdentifier = function(source)
        local player = exports.qbx_core:GetPlayer(tonumber(source))
        return player?.PlayerData?.citizenid or nil
    end,

    ---@param source number
    ---@return table
    GetPlayerName = function(source)
        local player = exports.qbx_core:GetPlayer(tonumber(source))
        if not player then return { fullName = '', firstName = '', lastName = '' } end
        return {
            fullName = (player.PlayerData?.charinfo?.firstname or '') .. ' ' .. (player.PlayerData?.charinfo?.lastname or ''),
            firstName = player.PlayerData?.charinfo?.firstname or '',
            lastName = player.PlayerData?.charinfo?.lastname or '',
        }
    end,

    ---@param source number
    ---@return 'male' | 'female' | nil
    GetPlayerGender = function(source)
        local player = exports.qbx_core:GetPlayer(tonumber(source))
        if not player then return nil end
        return player.PlayerData?.charinfo?.gender or nil
    end,

    ---@param source number
    ---@return table
    GetPlayerJob = function(source)
        local player = exports.qbx_core:GetPlayer(source)
        if not player then return { name = '', label = '', grade = 0, gradeLabel = '' } end

        local job = player.PlayerData?.job
        if not job then return { name = '', label = '', grade = 0, gradeLabel = '' } end

        return {
            name = job.name or '',
            label = job.label or '',
            grade = job.grade?.level or 0,
            gradeLabel = job.grade?.name or '',
        }
    end,

    ---@param source number
    ---@param jobName string
    ---@param jobGrade? number
    ---@return boolean
    PlayerHasJob = function(source, jobName, jobGrade)
        local player = exports.qbx_core:GetPlayer(source)
        if not player then return false end

        local currentJob = player.PlayerData?.job
        if not currentJob then return false end

        return currentJob.name == jobName and (not jobGrade or tonumber(currentJob.grade.level) >= jobGrade)
    end,

    ---@return number
    GetJobCount = function(jobName)
        local count = 0
        local players = exports.qbx_core:GetQBPlayers()

        for src, _ in pairs(players) do
            local player = exports.qbx_core:GetPlayer(src)

            if player then
                local job = player.PlayerData?.job

                if job.name == jobName and job.onduty then
                    count = count + 1
                end
            end
        end

        return count
    end,

    ---@param source number
    ---@param jobName string
    ---@param jobGrade? number
    SetPlayerJob = function(source, jobName, jobGrade)
        local player = exports.qbx_core:GetPlayer(source)
        if not player then return end

        local identifier = player.PlayerData?.citizenid
        exports.qbx_core:SetJob(identifier, jobName, jobGrade or 0)
    end,

    ---@return table
    GetAllPlayers = function()
        return exports.qbx_core:GetQBPlayers()
    end,

    ---@param itemName string Item name
    ---@param fn function Function to call when item is used
    RegisterUsableItem = function(itemName, fn)
        exports.qbx_core:CreateUseableItem(itemName, fn)
    end,
}
