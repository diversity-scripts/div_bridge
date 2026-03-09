local tgiann_inventory = exports['tgiann-inventory']
local Inventory = {}
Inventory.Stashes = Inventory.Stashes or {}

---@return string
Inventory.GetResourceName = function()
    return 'tgiann-inventory'
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item info (optional)
---@param slot? number Item slot (optional)
Inventory.AddItem = function(source, itemName, itemCount, metadata, slot)
    tgiann_inventory:AddItem(source, itemName, itemCount or 1, slot or nil, metadata or nil, false)
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param slot? number Item slot (optional)
---@param metadata? table Item info (optional)
Inventory.RemoveItem = function(source, itemName, itemCount, slot, metadata)
    tgiann_inventory:RemoveItem(source, itemName, itemCount or 1, slot or nil, metadata or nil)
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.CanCarryItem = function(source, itemName, itemCount)
    return tgiann_inventory:CanCarryItem(source, itemName, itemCount or 1)
end

---@param source number Source player ID
---@param items string | string[] Item name
---@return number
Inventory.GetItemCount = function(source, items)
    return tgiann_inventory:GetItemCount(source, items) or 0
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(source, itemName, itemCount)
    return tgiann_inventory:HasItem(source, itemName, itemCount)
end

---@param source number Source player ID
---@param itemName string Item name
---@param metadata? table Item metadata (optional)
---@return table
Inventory.GetItemByName = function(source, itemName, metadata)
    return tgiann_inventory:GetItemByName(source, itemName, metadata or nil) or {}
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata? table Item metadata (optional)
---@return table
Inventory.GetItemBySlot = function(source, slot, metadata)
    return tgiann_inventory:GetItemBySlot(source, slot, metadata or nil) or {}
end

---@param source number Source player ID
---@return table
Inventory.GetPlayerInventory = function(source)
    return tgiann_inventory:GetPlayerItems(source) or {}
end

---@param source number Source player ID
Inventory.ClearPlayerInventory = function(source)
    tgiann_inventory:ClearInventory(source)
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata table Item metadata
Inventory.SetMetadata = function(source, slot, metadata)
    if not slot or not metadata then return end
    local item = tgiann_inventory:GetItemBySlot(source, slot, metadata)
    if not item then return end
    tgiann_inventory:SetItemData(source, item.name, slot, metadata)
end

---@param stashId string | number Stash ID
---@param label string Stash label
---@param slots number Stash slots
---@param maxWeight number Stash max weight
---@param owner? string Owner identifier (unused)
---@param groups? table Groups allowed (unused)
---@param coords? vector3 Coordinates (unused)
Inventory.RegisterStash = function(stashId, label, slots, maxWeight, owner, groups, coords)
    if Inventory.Stashes[stashId] then return end
    Inventory.Stashes[stashId] = true
    tgiann_inventory:RegisterStash(stashId, label, slots, maxWeight)
end

---@param source number Source player ID
---@param _type string 'stash', 'trunk', 'glovebox'
---@param stashId string | number Stash ID
Inventory.OpenStash = function(source, _type, stashId)
    _type = _type or 'stash'
    tgiann_inventory:ForceOpenInventory(source, _type, stashId)
end

---@param stashId string | number Stash ID
---@param items table {item, count, metadata}
---@return boolean
Inventory.AddStashItems = function(stashId, items)
    if type(items) ~= 'table' then return false end
    local success = false
    for _, v in pairs(items) do
        if type(v) ~= 'table' then print('tgiann-inventory:AddStashItems - item is not a table') goto continue end
        if not v.item or not (v.count or v.amount) then print('tgiann-inventory:AddStashItems - item or count/amount is missing') goto continue end
        success = tgiann_inventory:AddItemToSecondaryInventory('stash', stashId, v.item, v.count or v.amount, nil, v.metadata or v.info or nil) or success
        ::continue::
    end
    return success
end

---@param stashId string Stash ID
---@return table
Inventory.GetStashItems = function(stashId)
    return tgiann_inventory:GetSecondaryInventoryItems('stash', stashId) or {}
end

---@param stashId string | number Stash ID
---@param _type? string Stash type
Inventory.ClearStash = function(stashId, _type)
    _type = _type or 'stash'
    local items = tgiann_inventory:GetSecondaryInventoryItems(_type, stashId)
    for _, v in pairs(items) do
        tgiann_inventory:RemoveItemFromSecondaryInventory(_type, stashId, v.item, v.count or v.amount, v.slot or nil, v.metadata or v.info or nil)
    end
    if Inventory.Stashes[stashId] then
        Inventory.Stashes[stashId] = nil
    end
end

---@param itemName string Item name
---@return string
Inventory.GetItemlabel = function(itemName)
    return tgiann_inventory:GetItemLabel(itemName) or itemName
end

---@param itemName? string Item name
---@return table
Inventory.Items = function(itemName)
    return tgiann_inventory:Items(itemName) or {}
end

return Inventory
