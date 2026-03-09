local ox_inventory = exports.ox_inventory
local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'ox_inventory'
end

---@param itemName string Item name
---@param metadata? table Item metadata (optional)
---@param strict? boolean Whether to strictly match metadata (optional)
---@return number
Inventory.GetItemCount = function(itemName, metadata, strict)
    return ox_inventory:GetItemCount(itemName, metadata or nil, strict or false) or 0
end

---@param itemName string Item name
---@param requiredCount? number Item count (optional)
---@return boolean
Inventory.HasItem = function(itemName, requiredCount)
    local count = ox_inventory:GetItemCount(itemName) or 0
    return count >= (requiredCount or 1)
end

---@return table
Inventory.GetPlayerInventory = function()
    return ox_inventory:GetPlayerItems() or {}
end

return Inventory
