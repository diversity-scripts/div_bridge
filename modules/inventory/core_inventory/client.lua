local core_inventory = exports.core_inventory
local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'core_inventory'
end

---@param itemName string Item name
---@return number
Inventory.GetItemCount = function(itemName)
    return core_inventory:getItemCount(itemName) or 0
end

---@param items string | string[] Item names
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(items, itemCount)
    return core_inventory:hasItem(items, itemCount) or false
end

---@return table
Inventory.GetPlayerInventory = function()
    return core_inventory:getInventory() or {}
end

return Inventory
