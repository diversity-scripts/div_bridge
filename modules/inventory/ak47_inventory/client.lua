local ak47_inventory = exports.ak47_inventory
local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'ak47_inventory'
end

---@param itemName string Item name
---@param metadata? table Item metadata (optional)
---@param strict? boolean Whether to strictly match metadata (optional)
---@return number
Inventory.GetItemCount = function(itemName, metadata, strict)
    return ak47_inventory:GetAmount(itemName, metadata or nil, strict or false) or 0
end

---@param items table Items
---@return boolean
Inventory.HasItem = function(items)
    return ak47_inventory:HasItems(items) or false
end

---@return table
Inventory.GetPlayerInventory = function()
    return ak47_inventory:GetPlayerItems() or {}
end

---@param itemName string Item name
---@return string
Inventory.GetItemLabel = function(itemName)
    return ak47_inventory:GetItemLabel(itemName) or ''
end

---@param itemName string Item name
---@return string
Inventory.GetImagePath = function(itemName)
    local pngPath = LoadResourceFile('ak47_inventory', ('web/build/images/%s.png'):format(itemName))
    local webpPath = LoadResourceFile('ak47_inventory', ('web/build/images/%s.webp'):format(itemName))
    local imagePath = pngPath and ('nui://ak47_inventory/web/build/images/%s.png'):format(itemName) or webpPath and ('nui://ak47_inventory/web/build/images/%s.webp'):format(itemName)
    return imagePath or ''
end

return Inventory
