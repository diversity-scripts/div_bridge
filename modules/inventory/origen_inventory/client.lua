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
    return origen_inventory:HasItem(itemName) or false
end

---@return table
Inventory.GetPlayerInventory = function()
    return origen_inventory:GetInventory() or {}
end

---@param itemName string Item name
---@return string
Inventory.GetImagePath = function(itemName)
    local pngPath = LoadResourceFile('origen_inventory', ('html/images/%s.png'):format(itemName))
    local webpPath = LoadResourceFile('origen_inventory', ('html/images/%s.webp'):format(itemName))
    local imagePath = pngPath and ('nui://origen_inventory/html/images/%s.png'):format(itemName) or webpPath and ('nui://origen_inventory/html/images/%s.webp'):format(itemName)
    return imagePath or ''
end

return Inventory
