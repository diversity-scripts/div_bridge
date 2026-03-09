local qs_inventory = exports['qs-inventory']
local Inventory = {}
Inventory.Stashes = Inventory.Stashes or {}

---@return string
Inventory.GetResourceName = function()
    return 'qs-inventory'
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item info (optional)
---@param slot? number Item slot (optional)
Inventory.AddItem = function(source, itemName, itemCount, metadata, slot)
    qs_inventory:AddItem(source, itemName, itemCount or 1, slot or nil, metadata or nil)
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param slot? number Item slot (optional)
---@param metadata? table Item info (optional)
Inventory.RemoveItem = function(source, itemName, itemCount, slot, metadata)
    qs_inventory:RemoveItem(source, itemName, itemCount or 1, slot or nil, metadata or nil)
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.CanCarryItem = function(source, itemName, itemCount)
    return qs_inventory:CanCarryItem(source, itemName, itemCount or 1)
end

---@param source number Source player ID
---@param itemName string Item name
---@return number
Inventory.GetItemCount = function(source, itemName)
    return qs_inventory:GetItemTotalAmount(source, itemName) or 0
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(source, itemName, itemCount)
    local itemTotalAmount = qs_inventory:GetItemTotalAmount(source, itemName)
    return itemTotalAmount >= (itemCount or 1)
end

---@param source number Source player ID
---@param itemName string Item name
---@return table
Inventory.GetItemByName = function(source, itemName)
    local inventory = qs_inventory:GetInventory(source)
    for _, item in pairs(inventory) do
        if item.name == itemName then
            return item
        end
    end

    return {}
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata? table Item metadata (unused)
---@return table
Inventory.GetItemBySlot = function(source, slot, metadata)
    local items = qs_inventory:GetInventory(source)
    for _, item in pairs(items) do
        if item.slot == slot then
            return item
        end
    end

    return {}
end

---@param source number Source player ID
---@return table
Inventory.GetPlayerInventory = function(source)
    return qs_inventory:GetInventory(source) or {}
end

---@param source number Source player ID
Inventory.ClearPlayerInventory = function(source)
    qs_inventory:ClearInventory(source)
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata table Item metadata
Inventory.SetMetadata = function(source, slot, metadata)
    qs_inventory:SetItemMetadata(source, slot, metadata)
end

---@param stashId string | number Stash ID
---@param label string Stash label (unused)
---@param slots number Stash slots
---@param maxWeight number Stash max weight
---@param owner? string Owner identifier (unused)
---@param groups? table Groups allowed (unused)
---@param coords? vector3 Coordinates (unused)
Inventory.RegisterStash = function(stashId, label, slots, maxWeight, owner, groups, coords)
    if Inventory.Stashes[stashId] then return end
    Inventory.Stashes[stashId] = { stashId = stashId, slots = slots, maxWeight = maxWeight }
    qs_inventory:RegisterStash(source, stashId, slots, maxWeight)
end

---@param source number Source player ID
---@param _type string 'stash', 'trunk', 'glovebox'
---@param stashId string | number Stash ID
Inventory.OpenStash = function(source, _type, stashId)
    _type = _type or "stash"
    if not Inventory.Stashes[stashId] then return end
    local stash = Inventory.Stashes[stashId]
    TriggerEvent('inventory:server:OpenInventory', _type, stashId, stash and { maxweight = stash.maxWeight or 5000, slots = stash.slots or 20 })
    TriggerClientEvent('inventory:client:SetCurrentStash', source, stashId)
end

---@param stashId string | number Stash ID (unused)
---@param items table Items to add (unused)
---@return boolean
Inventory.AddStashItems = function(stashId, items)
    return false, print('qs-inventory does not support adding items to stashes')
end

---@param stashId string Stash ID
---@return table
Inventory.GetStashItems = function(stashId)
    return qs_inventory:GetStashItems(stashId) or {}
end

---@param stashId string | number Stash ID (unused)
---@param _type? string Stash type (unused)
Inventory.ClearStash = function(stashId, _type)
    print('qs-inventory does not support clearing stashes')
end

---@param itemName string Item name
---@return string
Inventory.GetItemlabel = function(itemName)
    return qs_inventory:GetItemLabel(itemName) or itemName
end

---@param itemName? string Item name (unused)
---@return table
Inventory.Items = function(itemName)
    return qs_inventory:GetItemList()
end

return Inventory
