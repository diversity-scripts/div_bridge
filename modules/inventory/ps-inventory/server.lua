local QBCore = exports['qb-core']:GetCoreObject()
local ps_inventory = exports['ps-inventory']
local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'ps-inventory'
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@param slot? number Inventory slot (optional)
---@return boolean
Inventory.AddItem = function(source, itemName, itemCount, metadata, slot)
    return ps_inventory:AddItem(source, itemName, itemCount or 1, slot or nil, metadata or nil)
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@param slot? number Inventory slot (optional)
---@return boolean
Inventory.RemoveItem = function(source, itemName, itemCount, slot)
    return ps_inventory:RemoveItem(source, itemName, itemCount or 1, slot or nil)
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@return boolean
Inventory.CanCarryItem = function(source, itemName, itemCount, metadata)
    return true, print('ps-inventory does not provide "CanCarryItem" function. Weight is handled in the "AddItem" function.')
end

---@param source number Source player ID
---@param items string | string[] Item names
---@return number
Inventory.GetItemCount = function(source, items)
    local player = QBCore.Functions.GetPlayer(source)
    local items = player?.PlayerData?.items or {}
    local slot = ps_inventory:GetFirstSlotByItem(items, itemName)
    if not slot then return {} end

    return items[slot]?.amount or 0
end

---@param source number Source player ID
---@param item string Item name
---@param requiredCount number Item count
---@return boolean
Inventory.HasItem = function(source, item, requiredCount)
    return ps_inventory:HasItem(source, item, requiredCount or 1)
end

---@param source number Source player ID
---@param itemName string Item name
---@return table
Inventory.GetItemByName = function(source, itemName)
    return ps_inventory:GetItemByName(source, itemName)
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata? table Item metadata (unused)
---@return table
Inventory.GetItemBySlot = function(source, slot, metadata)
    return ps_inventory:GetItemBySlot(source, slot)
end

---@param source number Source player ID
---@return table
Inventory.GetPlayerInventory = function(source)
    local player = QBCore.Functions.GetPlayer(source)
    return player?.PlayerData?.items or {}
end

---@param source number Source player ID
Inventory.ClearPlayerInventory = function(source)
    print('ps-inventory does not provide "ClearInventory" function')
end

---@param source number Source player ID (unused)
---@param slot number Item slot (unused)
---@param metadata table Item metadata (unused)
Inventory.SetMetadata = function(source, slot, metadata)
    print('ps-inventory does not provide "SetMetadata" function')
end

---@param stashId string | number Stash ID (unused)
---@param label string Stash label (unused)
---@param slots number Stash slots (unused)
---@param maxWeight number Stash max weight (unused)
---@param owner? string Owner identifier (unused)
---@param groups? table Groups allowed (unused)
---@param coords? vector3 Coordinates (unused)
Inventory.RegisterStash = function(stashId, label, slots, maxWeight, owner, groups, coords)
    print('ps-inventory does not provide "RegisterStash" function. Stashes must be registered in the config.')
end

---@param source number Source player ID
---@param _type string 'stash', 'trunk', 'glovebox'
---@param stashId string Stash ID
Inventory.OpenStash = function(source, _type, stashId)
    _type = _type or 'stash'
    ps_inventory:OpenInventory(_type, stashId, nil, source)
end

---@param stashId string | number Stash ID (unused)
---@param items table Items to add (unused)
---@return boolean
Inventory.AddStashItems = function(stashId, items)
    return false, print('ps-inventory does not provide a way to add items to stashes')
end

---@param stashId string Stash ID
---@return table
Inventory.GetStashItems = function(stashId)
    return {}, print('ps-inventory does not provide a way to get stash items')
end

---@param stashId string | number Stash ID
---@param _type? string Stash type (unused)
Inventory.ClearStash = function(stashId, _type)
    print('ps-inventory does not provide a way to clear stashes')
end

---@param itemName string Item name
---@return string
Inventory.GetItemlabel = function(itemName)
    return QBCore?.Shared?.Items[itemName]?.label or itemName
end

---@param itemName? string Item name (unused)
---@return table
Inventory.Items = function(itemName)
    return QBCore?.Shared?.Items or {}
end

return Inventory
