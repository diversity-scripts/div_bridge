local origen_inventory = exports.origen_inventory
local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'origen_inventory'
end

---@param itemName string Item name
---@param metadata? table Item metadata
---@return number
Inventory.GetItemCount = function(itemName, metadata)
    return origen_inventory:Search('count', itemName, metadata or nil) or 0
end

---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(itemName, itemCount)
    local result = origen_inventory:HasItem(itemName) or 0
    return result >= (itemCount or 1)
end

---@return table
Inventory.GetPlayerInventory = function()
    return origen_inventory:GetInventory() or {}
end

return Inventory
