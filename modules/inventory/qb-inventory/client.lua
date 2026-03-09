local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'qb-inventory'
end

---@param itemName string Item name
---@return number
Inventory.GetItemCount = function(itemName)
    assert(Bridge.Framework.GetItemCount, 'Your framework does not provide a "GetItemCount" function. Please review your bridge config.')
    return Bridge.Framework:GetItemCount(itemName) or 0
end

---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(itemName, itemCount)
    assert(Bridge.Framework.HasItem, 'Your framework does not provide a "HasItem" function. Please review your bridge config.')
    return Bridge.Framework:HasItem(itemName, itemCount) or false
end

---@return table
Inventory.GetPlayerInventory = function()
    assert(Bridge.Framework.GetPlayerInventory, 'Your framework does not provide a "GetPlayerInventory" function. Please review your bridge config.')
    return Bridge.Framework:GetPlayerInventory() or {}
end

return Inventory
