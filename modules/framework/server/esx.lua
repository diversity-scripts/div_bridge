local ESX = exports.es_extended:getSharedObject()

return {
    ---@param source number
    ---@return table | nil
    GetPlayerFromId = function(source)
        return ESX.GetPlayerFromId(tonumber(source)) or nil
    end,

    ---@param identifier string
    ---@return table | nil
    GetPlayerFromIdentifier = function(identifier)
        return ESX.GetPlayerFromIdentifier(identifier) or nil
    end,

    ---@param source number
    ---@return string | nil
    GetPlayerIdentifier = function(source)
        local xPlayer = ESX.GetPlayerFromId(tonumber(source))
        return xPlayer?.getIdentifier() or nil
    end,

    ---@param source number
    ---@return table
    GetPlayerName = function(source)
        local xPlayer = ESX.GetPlayerFromId(tonumber(source))
        if not xPlayer then return { fullName = '', firstName = '', lastName = '' } end
        return {
            fullName = xPlayer.getName() or '',
            firstName = xPlayer.get('firstName') or '',
            lastName = xPlayer.get('lastName') or '',
        }
    end,

    ---@param source number
    ---@return 'male' | 'female' | nil
    GetPlayerGender = function(source)
        local xPlayer = ESX.GetPlayerFromId(tonumber(source))
        return xPlayer?.get('sex') and (xPlayer.get('sex') == 'm' and 'male' or 'female') or nil
    end,

    ---@param source number
    ---@return table
    GetPlayerJob = function(source)
        local xPlayer = ESX.GetPlayerFromId(tonumber(source))
        if not xPlayer then return { name = '', label = '', grade = 0, gradeLabel = '' } end

        local currentJob = xPlayer.getJob()
        if not currentJob then return { name = '', label = '', grade = 0, gradeLabel = '' } end

        return {
            name = currentJob.name or '',
            label = currentJob.label or '',
            grade = currentJob.grade or 0,
            gradeLabel = currentJob.grade_label or '',
        }
    end,

    ---@param source number
    ---@param jobName string
    ---@param jobGrade? number
    ---@return boolean
    PlayerHasJob = function(source, jobName, jobGrade)
        local xPlayer = ESX.GetPlayerFromId(tonumber(source))
        if not xPlayer then return false end

        local currentJob = xPlayer.getJob()
        if not currentJob then return false end

        return currentJob and currentJob.name == jobName and (not jobGrade or tonumber(currentJob.grade) >= jobGrade)
    end,

    ---@param jobName string
    ---@return number
    GetJobCount = function(jobName)
        local xPlayers = ESX.GetExtendedPlayers('job', jobName)
        return #xPlayers
    end,

    ---@param source number
    ---@param jobName string
    ---@param jobGrade? number
    SetPlayerJob = function(source, jobName, jobGrade)
        local xPlayer = ESX.GetPlayerFromId(tonumber(source))
        if not xPlayer then return end
        xPlayer.setJob(jobName, jobGrade or 0)
    end,

    ---@return table
    GetAllPlayers = function()
        return ESX.GetExtendedPlayers()
    end,

    ---@param itemName string Item name
    ---@param fn function Function to call when item is used
    RegisterUsableItem = function(itemName, fn)
        ESX.RegisterUsableItem(itemName, fn)
    end,
}