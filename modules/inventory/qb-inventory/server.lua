local QBCore = exports['qb-core']:GetCoreObject()
local qb_inventory = exports['qb-inventory']
local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'qb-inventory'
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param info? table Item info (optional)
---@param slot? number Item slot (optional)
---@return boolean
Inventory.AddItem = function(source, itemName, itemCount, info, slot)
    return qb_inventory:AddItem(source, itemName, itemCount or 1, slot or false, info or false)
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param slot? number Item slot (optional)
---@return boolean
Inventory.RemoveItem = function(source, itemName, itemCount, slot)
    return qb_inventory:RemoveItem(source, itemName, itemCount or 1, slot or false)
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.CanCarryItem = function(source, itemName, itemCount)
    local canAdd, _ = qb_inventory:CanAddItem(source, itemName, itemCount or 1)
    return canAdd
end

---@param source number Source player ID
---@param items string | string[] Item names
---@return number
Inventory.GetItemCount = function(source, items)
    return qb_inventory:GetItemCount(source, items) or 0
end

---@param source number Source player ID
---@param items string | string[] Item names
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(source, items, itemCount)
    return qb_inventory:HasItem(source, items, itemCount or 1)
end

---@param source number Source player ID
---@param itemName string Item name
---@return table
Inventory.GetItemByName = function(source, itemName)
    return qb_inventory:GetItemByName(source, itemName) or {}
end

---@param source number Source player ID (unused)
---@param slot number Item slot (unused)
---@param metadata? table Item metadata (unused)
---@return table
Inventory.GetItemBySlot = function(source, slot, metadata)
    return qb_inventory:GetItemBySlot(source, slot) or {}
end

---@param source number Source player ID
---@return table
Inventory.GetPlayerInventory = function(source)
    return qb_inventory:GetInventory(source) or {}
end

---@param source number Source player ID
Inventory.ClearPlayerInventory = function(source)
    qb_inventory:ClearInventory(source)
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata table Item metadata
Inventory.SetMetadata = function(source, slot, metadata)
    local item = Inventory.GetItemBySlot(source, slot)
    if not item then return end
    local amount = item.amount or item.count or 1
    Inventory.RemoveItem(source, item.name, amount, slot)
    Inventory.AddItem(source, item.name, amount, metadata or {}, slot)
end

---@param stashId string | number Stash ID
---@param label string Stash label
---@param slots number Stash slots
---@param maxWeight number Stash max weight
---@param owner? string Owner identifier (unused)
---@param groups? table Groups allowed (unused)
---@param coords? vector3 Coordinates (unused)
Inventory.RegisterStash = function(stashId, label, slots, maxWeight, owner, groups, coords)
    local data = { label = label, slots = slots or 50, maxweight = maxWeight or 100000 }
    qb_inventory:OpenInventory(source, stashId, data)
end

---@param source number Source player ID
---@param _type string 'stash', 'trunk', 'glovebox' (unused)
---@param stashId string | number Stash ID
Inventory.OpenStash = function(source, stashId)
    qb_inventory:OpenInventory(source, stashId)
end

---@param stashId string | number Stash ID
---@param items table Items to add
Inventory.AddStashItems = function(stashId, items)
    if type(items) ~= 'table' then return false end
    local success = false
    for _, item in pairs(items) do
        if type(item) ~= 'table' then print('qb-inventory:AddStashItems - item is not a table') goto continue end
        if not item.item or not (item.count or item.amount) then print('qb-inventory:AddStashItems - item or count/amount is missing') goto continue end
        success = qb_inventory:AddItem(stashId, item.item, item.count or item.amount, nil, item.metadata or item.info or nil) or success
        ::continue::
    end
    return success
end

---@param stashId string Stash ID
---@return table
Inventory.GetStashItems = function(stashId)
    local invData = qb_inventory:GetInventory(stashId)
    if invData == nil or invData == {} then
        return {}
    end

    return invData.items
end

---@param stashId string | number Stash ID
---@param _type? string Stash type
Inventory.ClearStash = function(stashId, _type)
    if type(stashId) ~= 'string' then return false end

    local id = stashId
    if _type == 'trunk' then
        id = 'trunk-' .. id
    elseif _type == 'glovebox' then
        id = 'glovebox-' .. id
    end

    local inv = qb_inventory:GetInventory(id)
    if not inv then return true end
    qb_inventory:ClearStash(id)

    if Inventory.Stashes[stashId] then
        Inventory.Stashes[stashId] = nil
    end
end

---@param itemName string Item name
---@return string
Inventory.GetItemLabel = function(itemName)
    return itemName
end

---@param itemName? string Item name (unused)
---@return table
Inventory.Items = function(itemName)
    return {}
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
