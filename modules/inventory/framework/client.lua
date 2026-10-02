local Inventory = {}

local framework = dBridge.getFramework('Inventory')

---@return string
Inventory.GetResourceName = function()
    return 'framework'
end

---@param itemName string Item name
---@return number
Inventory.GetItemCount = function(itemName)
    assert(framework.GetItemCount, 'Your framework does not provide a client-side "GetItemCount" function.')
    return framework:GetItemCount(itemName) or 0
end

---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(itemName, itemCount)
    assert(framework.HasItem, 'Your framework does not provide a client-side "HasItem" function.')
    return framework:HasItem(itemName, itemCount) or false
end

---@return table
Inventory.GetPlayerInventory = function()
    assert(framework.GetPlayerInventory, 'Your framework does not provide a client-side "GetPlayerInventory" function.')
    return framework:GetPlayerInventory() or {}
end

return Inventory
