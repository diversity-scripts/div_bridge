local Banking = {}

local tgiann_bank = exports["tgiann-bank"]

---@return string
Banking.GetResourceName = function()
    return 'tgiann-bank'
end

---@param account string Account name/identifier
---@return number
Banking.GetPlayerAccountBalance = function(account)
    return tgiann_bank:GetAccountBalance(account) or 0
end

---@param account string Account name/identifier
---@param amount number Amount to add
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.AddPlayerAccountBalance = function(account, amount, reason)
    return tgiann_bank:AddMoney(account, amount)
end

---@param account string Account name/identifier
---@param amount number Amount to remove
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.RemovePlayerAccountBalance = function(account, amount, reason)
    return tgiann_bank:RemoveMoney(account, amount)
end

---@param account string Account name/identifier
---@return number
Banking.GetJobAccountBalance = function(account)
    return tgiann_bank:GetJobAccountBalance(account) or 0
end

---@param account string Account name/identifier
---@param amount number Amount to add
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.AddJobAccountBalance = function(account, amount, reason)
    return tgiann_bank:AddJobMoney(account, amount)
end

---@param account string Account name/identifier
---@param amount number Amount to remove
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.RemoveJobAccountBalance = function(account, amount, reason)
    return tgiann_bank:RemoveJobMoney(account, amount)
end

return Banking