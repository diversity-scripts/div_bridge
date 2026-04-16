local Banking = {}

local okokBanking = exports.okokBanking

---@return string
Banking.GetResourceName = function()
    return 'okokBanking'
end

---@param account string Account name/identifier
---@return number
Banking.GetPlayerAccountBalance = function(account)
    return okokBanking:GetAccount(account) or 0
end

---@param account string Account name/identifier
---@param amount number Amount to add
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.AddPlayerAccountBalance = function(account, amount, reason)
    return okokBanking:AddMoney(account, amount)
end

---@param account string Account name/identifier
---@param amount number Amount to remove
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.RemovePlayerAccountBalance = function(account, amount, reason)
    return okokBanking:RemoveMoney(account, amount)
end

---@param account string Account name/identifier
---@return number
Banking.GetJobAccountBalance = function(account)
    return okokBanking:GetAccount(account) or 0
end

---@param account string Account name/identifier
---@param amount number Amount to add
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.AddJobAccountBalance = function(account, amount, reason)
    return okokBanking:AddMoney(account, amount)
end

---@param account string Account name/identifier
---@param amount number Amount to remove
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.RemoveJobAccountBalance = function(account, amount, reason)
    return okokBanking:RemoveMoney(account, amount)
end

return Banking