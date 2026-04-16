local Banking = {}

local function getFramework()
    local framework = Bridge.Framework
    if type(framework) ~= 'table' then
        error('Banking: Bridge.Framework failed to load or is invalid. Please check your config.')
    end
    return framework
end

local framework = getFramework()

---@return string
Banking.GetResourceName = function()
    return 'framework'
end

---@param source number Player ID
---@param account string Account name/identifier (unused)
---@return number
Banking.GetPlayerAccountBalance = function(source, account)
    if type(source) ~= 'number' then
        error('[Banking] GetPlayerAccountBalance: First argument must be source and must be a number.')
    end
    assert(framework.GetPlayerAccountBalance, 'Your framework does not provide a server-side "GetPlayerAccountBalance" function.')
    return framework:GetPlayerAccountBalance(source, 'bank') or 0
end

---@param source number Player ID
---@param account string Account name/identifier (unused)
---@param amount number Amount to add
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.AddPlayerAccountBalance = function(source, account, amount, reason)
    if type(source) ~= 'number' then
        error('[Banking] AddPlayerAccountBalance: First argument must be source and must be a number.')
    end
    assert(framework.AddPlayerAccountBalance, 'Your framework does not provide a server-side "AddPlayerAccountBalance" function.')
    return framework:AddPlayerAccountBalance(source, 'bank', amount)
end

---@param source number Player ID
---@param account string Account name/identifier (unused)
---@param amount number Amount to remove
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.RemovePlayerAccountBalance = function(source, account, amount, reason)
    if type(source) ~= 'number' then
        error('[Banking] RemovePlayerAccountBalance: First argument must be source and must be a number.')
    end
    assert(framework.RemovePlayerAccountBalance, 'Your framework does not provide a server-side "RemovePlayerAccountBalance" function.')
    return framework:RemovePlayerAccountBalance(source, 'bank', amount)
end

---@param source number Player ID
---@param account string Account name/identifier (unused)
---@return number
Banking.GetJobAccountBalance = function(source, account)
    if type(source) ~= 'number' then
        error('[Banking] GetJobAccountBalance: First argument must be source and must be a number.')
    end
    assert(framework.GetJobAccountBalance, 'Your framework does not provide a server-side "GetJobAccountBalance" function.')
    return framework:GetJobAccountBalance(source, 'bank') or 0
end

---@param source number Player ID
---@param account string Account name/identifier (unused)
---@param amount number Amount to add
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.AddJobAccountBalance = function(source, account, amount, reason)
    if type(source) ~= 'number' then
        error('[Banking] AddJobAccountBalance: First argument must be source and must be a number.')
    end
    assert(framework.AddJobAccountBalance, 'Your framework does not provide a server-side "AddJobAccountBalance" function.')
    return framework:AddJobAccountBalance(source, 'bank', amount)
end

---@param source number Player ID
---@param account string Account name/identifier (unused)
---@param amount number Amount to remove
---@param reason string Reason for the transaction (unused)
---@return boolean
Banking.RemoveJobAccountBalance = function(source, account, amount, reason)
    if type(source) ~= 'number' then
        error('[Banking] RemoveJobAccountBalance: First argument must be source and must be a number.')
    end
    assert(framework.RemoveJobAccountBalance, 'Your framework does not provide a server-side "RemoveJobAccountBalance" function.')
    return framework:RemoveJobAccountBalance(source, 'bank', amount)
end

return Banking