local jaksam_inventory = exports['jaksam_inventory']
local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'jaksam_inventory'
end

---@param itemName string Item name
---@return number
Inventory.GetItemCount = function(itemName)
    return jaksam_inventory:getTotalItemAmount(itemName) or 0
end

---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(itemName, itemCount)
    local result = jaksam_inventory:getTotalItemAmount(itemName) or 0
    return result >= (itemCount or 1)
end

---@return table
Inventory.GetPlayerInventory = function()
    return jaksam_inventory:getInventory() or {}
end

---@param itemName string Item name
---@return string
Inventory.GetImagePath = function(itemName)
    return jaksam_inventory:getItemImagePath(itemName) or ''
end

return Inventory
