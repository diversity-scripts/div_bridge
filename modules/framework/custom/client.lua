local Framework = {}

---@return string
Framework.GetResourceName = function()
    return 'custom'
end

-- [[ Player Related ]] --

---This will return true if the player is loaded, false otherwise
---@return boolean
Framework.IsPlayerLoaded = function()
    return true
end

---This is an internal function, do not use this outside of bridge as there is no standard format between the frameworks
---@return table
Framework.GetPlayerData = function()
    return {}
end

---This will get the players identifier (citizenid)
---@return string | nil
Framework.GetPlayerIdentifier = function()
    return nil
end


---This will get the players name
---@return table {fullName, firstName, lastName}
Framework.GetPlayerName = function()
    return {
        fullName = '',
        firstName = '',
        lastName = '',
    }
end

---This will get the players gender
---@return 'male' | 'female' | nil
Framework.GetPlayerGender = function()
    return 'male'
end

---This will get the players birth date
---@return string
Framework.GetPlayerDob = function()
    return ''
end

---This will get a players dead status
---@return boolean
Framework.IsPlayerDead = function()
    return false
end

---This will return the players job
---@return table {name, label, grade, gradeLabel}
Framework.GetPlayerJob = function()
    return {
        name = '',
        label = '',
        grade = 0,
        gradeLabel = '',
    }
end

---This will return true if player has the job, false otherwise
---@param jobName string
---@param jobGrade? number
---@return boolean
Framework.PlayerHasJob = function(jobName, jobGrade)
    return true
end

---This will get the players group
---@return string | nil
Framework.GetPlayerGroup = function()
    return nil
end

---This will check for the closest player¨
---@param distance? number
---@return number playerId, number distance
Framework.GetClosestPlayer = function(distance)
    return 0, 0
end

---This will check for the closest vehicle
---@param distance? number
---@return number vehicleId, number distance
Framework.GetClosestVehicle = function(distance)
    return 0, 0
end

-- [[ UI Related ]] --

---This will send a notification to the player
---@param msg string
---@param _type? 'success' | 'error' | 'info' | 'warning'
---@param duration? number
Framework.Notify = function(msg, _type, duration)
    -- Add custom notification logic here
    print(('[Notify] %s (%s) - %dms'):format(msg, _type, duration or 5000))
end

---This will display the help text message on the screen
---@param text string
Framework.ShowTextUI = function(text)
    print(text)
end

---This will hide the help text message on the screen
Framework.HideTextUI = function()

end

-- [[ Account Related ]] --

---This will return the players money by account type
---@param accountType 'cash' | 'bank'
---@return number
Framework.GetAccountBalance = function(accountType)
    return 0
end

-- [[ Inventory Related ]] --

---This is an internal function used as a fallback, please use the Inventory.GetItemCount instead.
---@param itemName string Item name
---@return number
Framework.GetItemCount = function(itemName)
    return 0
end

---This is an internal function used as a fallback, please use the Inventory.HasItem instead.
---@param itemName string Item name
---@param requiredCount number Item count (optional)
---@return boolean
Framework.HasItem = function(itemName, requiredCount)
    return false
end

---This is an internal function used as a fallback, please use the Inventory.GetPlayerInventory instead.
---@return table {name, label, count, slot, metadata, stack, close, weight}
Framework.GetPlayerInventory = function()
    return {}
end

return Framework