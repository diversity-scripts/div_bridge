local qs_inventory = exports['qs-inventory']
local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'qs-inventory'
end

---@param itemName string Item name
---@return number
Inventory.GetItemCount = function(itemName)
    return qs_inventory:Search(itemName) or 0
end

---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(itemName, itemCount)
    local result = qs_inventory:Search(itemName) or 0
    return result >= (itemCount or 1)
end

---@return table
Inventory.GetPlayerInventory = function()
    return qs_inventory:getUserInventory() or {}
end

return Inventory
