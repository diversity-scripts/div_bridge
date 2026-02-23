Bridge.loadLib()

local NDCore = exports['ND_Core']

return {
    ---@param source number
    ---@return table | nil
    GetPlayerFromId = function(source)
        return NDCore:getPlayer(tonumber(source)) or nil
    end,

    ---@param identifier string
    ---@return table | nil
    GetPlayerFromIdentifier = function(identifier)
        local players = NDCore:getPlayers()
        for _, player in pairs(players) do
            if player.identifier == identifier then
                return player
            end
        end
        return nil
    end,

    ---@param source number
    ---@return string | nil
    GetPlayerIdentifier = function(source)
        local player = NDCore:getPlayer(tonumber(source))
        return player?.identifier or nil
    end,

    ---@param source number
    ---@return table
    GetPlayerName = function(source)
        local player = NDCore:getPlayer(tonumber(source))
        if not player then return { fullName = '', firstName = '', lastName = '' } end
        return {
            fullName = player.fullname,
            firstName = player.firstname or '',
            lastName = player.lastname or '',
        }
    end,

    ---@param source number
    ---@return 'male' | 'female' | nil
    GetPlayerGender = function(source)
        local player = NDCore:getPlayer(tonumber(source))
        if not player then return nil end
        return player?.gender or nil
    end,

    ---@param source number
    ---@return table
    GetPlayerJob = function(source)
        local player = NDCore:getPlayer(source)
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
    end,

    ---@param source number
    ---@param jobName string
    ---@param jobGrade? number
    ---@return boolean
    PlayerHasJob = function(source, jobName, jobGrade)
        local player = NDCore:getPlayer(source)
        if not player then return false end

        local job = player.job or {}
        local jobInfo = player.jobInfo or {}

        return job == jobName and (not jobGrade or jobInfo.rank >= jobGrade)
    end,

    ---@return number
    GetJobCount = function(jobName)
        local count = 0
        local players = NDCore:getPlayers('job', jobName, false)

        for _, playerData in pairs(players) do
            if playerData then
                local job = playerData.job or {}
                local jobInfo = playerData.jobInfo or {}

                if job and job == jobName then
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
        local player = NDCore:getPlayer(source)
        if not player then return end

        player.setJob(jobName, jobGrade)
    end,

    ---@return table
    GetAllPlayers = function()
        return NDCore:getPlayers()
    end,

    ---@param itemName string Item name
    ---@param fn function Function to call when item is used
    RegisterUsableItem = function(itemName, fn)
        -- ND Core does not have a function to register usable items
    end,
}