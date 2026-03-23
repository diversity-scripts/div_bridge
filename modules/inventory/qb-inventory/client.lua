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

---@param itemName string Item name
---@return string
Inventory.GetImagePath = function(itemName)
    local pngPath = LoadResourceFile('qb-inventory', ('html/images/%s.png'):format(itemName))
    local webpPath = LoadResourceFile('qb-inventory', ('html/images/%s.webp'):format(itemName))
    local imagePath = pngPath and ('nui://qb-inventory/html/images/%s.png'):format(itemName) or webpPath and ('nui://qb-inventory/html/images/%s.webp'):format(itemName)
    return imagePath or ''
end

return Inventory
