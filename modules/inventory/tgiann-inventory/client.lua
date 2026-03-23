local tgiann_inventory = exports['tgiann-inventory']
local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'tgiann-inventory'
end

---@param itemName string Item name
---@param metadata? table Item metadata (optional)
---@param strict? boolean Whether to strictly match metadata (optional)
---@return number
Inventory.GetItemCount = function(itemName, metadata, strict)
    return tgiann_inventory:GetItemCount(itemName, metadata or nil, strict or false) or 0
end

---@param items string | string[] Item name
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(items, itemCount)
    return tgiann_inventory:HasItem(items, itemCount)
end

---@return table
Inventory.GetPlayerInventory = function()
    return tgiann_inventory:GetPlayerItems() or {}
end

---@param itemName string Item name
---@return string
Inventory.GetImagePath = function(itemName)
    local pngPath = LoadResourceFile('inventory_images', ('images/%s.png'):format(itemName))
    local webpPath = LoadResourceFile('inventory_images', ('images/%s.webp'):format(itemName))
    local imagePath = pngPath and ('nui://inventory_images/images/%s.png'):format(itemName) or webpPath and ('nui://inventory_images/images/%s.webp'):format(itemName)
    return imagePath or ''
end

return Inventory