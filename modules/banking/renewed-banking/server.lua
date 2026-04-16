local Banking = {}

local renewed_banking = exports['Renewed-Banking']

---@return string
Banking.GetResourceName = function()
    return 'Renewed-Banking'
end

---@param account string Account name/identifier
---@return number
Banking.GetPlayerAccountBalance = function(account)
    return renewed_banking:GetAccountBalance(account) or 0
end

---@param account string Account name/identifier
---@param amount number Amount to add
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.AddPlayerAccountBalance = function(account, amount, reason)
    return renewed_banking:AddAccountBalance(account, amount)
end

---@param account string Account name/identifier
---@param amount number Amount to remove
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.RemovePlayerAccountBalance = function(account, amount, reason)
    return renewed_banking:RemoveAccountBalance(account, amount)
end

---@param account string Account name/identifier
---@return number
Banking.GetJobAccountBalance = function(account)
    return renewed_banking:GetAccountBalance(account) or 0
end

---@param account string Account name/identifier
---@param amount number Amount to add
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.AddJobAccountBalance = function(account, amount, reason)
    return renewed_banking:AddAccountBalance(account, amount)
end

---@param account string Account name/identifier
---@param amount number Amount to remove
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.RemoveJobAccountBalance = function(account, amount, reason)
    return renewed_banking:RemoveAccountBalance(account, amount)
end

return Banking