local Banking = {}

local fd_banking = exports['fd_banking']

---@return string
Banking.GetResourceName = function()
    return 'fd_banking'
end

---@param account string Account name/identifier
---@return number
Banking.GetPlayerAccountBalance = function(account)
    return fd_banking:GetAccount(account) or 0
end

---@param account string Account name/identifier
---@param amount number Amount to add
---@param reason string Reason for the transaction
---@return boolean
Banking.AddPlayerAccountBalance = function(account, amount, reason)
    return fd_banking:AddMoney(account, amount, reason)
end

---@param account string Account name/identifier
---@param amount number Amount to remove
---@param reason string Reason for the transaction
---@return boolean
Banking.RemovePlayerAccountBalance = function(account, amount, reason)
    return fd_banking:RemoveMoney(account, amount, reason)
end

---@param account string Account name/identifier
---@return number
Banking.GetJobAccountBalance = function(account)
    return fd_banking:GetAccount(account) or 0
end

---@param account string Account name/identifier
---@param amount number Amount to add
---@param reason string Reason for the transaction
---@return boolean
Banking.AddJobAccountBalance = function(account, amount, reason)
    return fd_banking:AddMoney(account, amount, reason)
end

---@param account string Account name/identifier
---@param amount number Amount to remove
---@param reason string Reason for the transaction
---@return boolean
Banking.RemoveJobAccountBalance = function(account, amount, reason)
    return fd_banking:RemoveMoney(account, amount, reason)
end

return Banking