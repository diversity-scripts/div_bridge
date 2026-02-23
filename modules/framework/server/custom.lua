return {
    ---@param source number
    ---@return table | nil
    GetPlayerFromId = function(source)
        return nil
    end,

    ---@param identifier string
    ---@return table | nil
    GetPlayerFromIdentifier = function(identifier)
        return nil
    end,

    ---@param source number
    ---@return string | nil
    GetPlayerIdentifier = function(source)
        local xPlayer = ESX.GetPlayerFromId(tonumber(source))
        return nil
    end,

    ---@param source number
    ---@return table
    GetPlayerName = function(source)
        return {
            fullName = '',
            firstName = '',
            lastName = '',
        }
    end,

    ---@param source number
    ---@return 'male' | 'female' | nil
    GetPlayerGender = function(source)
        return 'male'
    end,

    ---@param source number
    ---@return table
    GetPlayerJob = function(source)
        return {
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
        return true
    end,

    ---@param jobName string
    ---@return number
    GetJobCount = function(jobName)
        return 0
    end,

    ---@param source number
    ---@param jobName string
    ---@param jobGrade? number
    SetPlayerJob = function(source, jobName, jobGrade)

    end,

    ---@return table
    GetAllPlayers = function()
        return {}
    end,

    ---@param itemName string Item name
    ---@param fn function Function to call when item is used
    RegisterUsableItem = function(itemName, fn)

    end,
}