local Banking = {}

local kartik_banking = exports['kartik-banking']

---@return string
Banking.GetResourceName = function()
    return 'kartik-banking'
end

---@param account string Account name/identifier
---@return number
Banking.GetPlayerAccountBalance = function(account)
    return kartik_banking:GetAccountBalance(account) or 0
end

---@param account string Account name/identifier
---@param amount number Amount to add
---@param reason string Reason for the transaction
---@return boolean
Banking.AddPlayerAccountBalance = function(account, amount, reason)
    return kartik_banking:AddAccountBalance(account, amount, reason)
end

---@param account string Account name/identifier
---@param amount number Amount to remove
---@param reason string Reason for the transaction
---@return boolean
Banking.RemovePlayerAccountBalance = function(account, amount, reason)
    return kartik_banking:RemoveAccountBalance(account, amount, reason)
end

---@param account string Account name/identifier
---@return number
Banking.GetJobAccountBalance = function(account)
    return kartik_banking:GetAccountBalance(account) or 0
end

---@param account string Account name/identifier
---@param amount number Amount to add
---@param reason string Reason for the transaction
---@return boolean
Banking.AddJobAccountBalance = function(account, amount, reason)
    return kartik_banking:AddAccountBalance(account, amount, reason)
end

---@param account string Account name/identifier
---@param amount number Amount to remove
---@param reason string Reason for the transaction
---@return boolean
Banking.RemoveJobAccountBalance = function(account, amount, reason)
    return kartik_banking:RemoveAccountBalance(account, amount, reason)
end

return Banking