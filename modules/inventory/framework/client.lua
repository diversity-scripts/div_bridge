local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'framework'
end

local function getFramework()
    local framework = Bridge.Framework
    if type(framework) ~= 'table' then
        error('Bridge.Framework failed to load or is invalid. Please check your config.')
    end
    return framework
end

---@param itemName string Item name
---@return number
Inventory.GetItemCount = function(itemName)
    local framework = getFramework()
    assert(framework.GetItemCount, 'Your framework does not provide a "GetItemCount" function.')
    return framework:GetItemCount(itemName) or 0
end

---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(itemName, itemCount)
    local framework = getFramework()
    assert(framework.HasItem, 'Your framework does not provide a "HasItem" function.')
    return framework:HasItem(itemName, itemCount) or false
end

---@return table
Inventory.GetPlayerInventory = function()
    local framework = getFramework()
    assert(framework.GetPlayerInventory, 'Your framework does not provide a "GetPlayerInventory" function.')
    return framework:GetPlayerInventory() or {}
end

return Inventory
