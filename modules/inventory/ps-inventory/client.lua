local QBCore = exports['qb-core']:GetCoreObject()
local ps_inventory = exports['ps-inventory']
local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'ps-inventory'
end

local function getFirstSlotByItem(items, itemName)
    for slot, item in pairs(items) do
        if item.name == itemName then
            return slot
        end
    end
    return nil
end

---@param itemName string Item name
---@return number
Inventory.GetItemCount = function(itemName)
    local playerData = QBCore.Functions.GetPlayerData()
    local items = playerData?.items or {}
    local slot = getFirstSlotByItem(items, itemName)
    if not slot then return 0 end

    return items[slot]?.amount or 0
end

---@param itemName string Item name
---@return boolean
Inventory.HasItem = function(itemName)
    return ps_inventory:HasItem(itemName) or false
end

---@return table
Inventory.GetPlayerInventory = function()
    local playerData = QBCore.Functions.GetPlayerData()
    return playerData?.items or {}
end

---@param itemName string Item name
---@return string
Inventory.GetImagePath = function(itemName)
    local pngPath = LoadResourceFile('ps-inventory', ('html/images/%s.png'):format(itemName))
    local webpPath = LoadResourceFile('ps-inventory', ('html/images/%s.webp'):format(itemName))
    local imagePath = pngPath and ('nui://ps-inventory/html/images/%s.png'):format(itemName) or webpPath and ('nui://ps-inventory/html/images/%s.webp'):format(itemName)
    return imagePath or ''
end

return Inventory
