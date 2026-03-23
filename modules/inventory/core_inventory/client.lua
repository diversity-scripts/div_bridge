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

---@param itemName string Item name
---@return string
Inventory.GetImagePath = function(itemName)
    local pngPath = LoadResourceFile('core_inventory', ('html/img/%s.png'):format(itemName))
    local webpPath = LoadResourceFile('core_inventory', ('html/img/%s.webp'):format(itemName))
    local imagePath = pngPath and ('nui://core_inventory/html/img/%s.png'):format(itemName) or webpPath and ('nui://core_inventory/html/img/%s.webp'):format(itemName)
    return imagePath or ''
end

return Inventory
