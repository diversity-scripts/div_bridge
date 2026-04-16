local Banking = {}

---@return string
Banking.GetResourceName = function()
    return 'custom'
end

---@param accountId string | number Account name/identifier
---@return number
Banking.GetPlayerAccountBalance = function(accountId)
    return 0
end

---@param accountId string | number Account name/identifier
---@param amount number Amount to add
---@param reason? string Reason for the transaction
---@return boolean
Banking.AddPlayerAccountBalance = function(accountId, amount, reason)
    return true
end

---@param accountId string | number Account name/identifier
---@param amount number Amount to remove
---@param reason? string Reason for the transaction
---@return boolean
Banking.RemovePlayerAccountBalance = function(accountId, amount, reason)
    return true
end

---@param accountId string | number Account name/identifier
---@return number
Banking.GetJobAccountBalance = function(accountId)
    return 0
end

---@param accountId string | number Account name/identifier
---@param amount number Amount to add
---@param reason? string Reason for the transaction
---@return boolean
Banking.AddJobAccountBalance = function(accountId, amount, reason)
    return true
end

---@param accountId string | number Account name/identifier
---@param amount number Amount to remove
---@param reason? string Reason for the transaction
---@return boolean
Banking.RemoveJobAccountBalance = function(accountId, amount, reason)
    return true
end

return Banking