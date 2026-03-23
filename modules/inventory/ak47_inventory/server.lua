local ak47_inventory = exports.ak47_inventory
local Inventory = {}
Inventory.Stashes = Inventory.Stashes or {}

---@return string
Inventory.GetResourceName = function()
    return 'ak47_inventory'
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@param slot? number Slot number (optional)
---@return boolean
Inventory.AddItem = function(source, itemName, itemCount, metadata, slot)
    return ak47_inventory:AddItem(source, itemName, itemCount or 1, slot or nil, metadata or nil)
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param slot? number Slot number (optional)
---@return boolean
Inventory.RemoveItem = function(source, itemName, itemCount, slot)
    return ak47_inventory:RemoveItem(source, itemName, itemCount or 1, slot or nil)
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.CanCarryItem = function(source, itemName, itemCount)
    return ak47_inventory:CanAddItem(source, itemName, itemCount)
end

---@param source number Source player ID
---@param item string Item name
---@param metadata? table Item metadata (optional)
---@param strict? boolean Whether to strictly match metadata (optional)
---@return number
Inventory.GetItemCount = function(source, item, metadata, strict)
    return ak47_inventory:GetAmount(source, item, metadata or nil, strict or false) or 0
end

---@param source number Source player ID
---@param items table Item names
---@return boolean | table
Inventory.HasItem = function(source, items)
    return ak47_inventory:HasItems(source, items)
end

---@param source number Source player ID
---@param itemName string Item name
---@param metadata? table Item metadata (optional)
---@param strict? boolean Whether to strictly match metadata (optional)
---@return table
Inventory.GetItemByName = function(source, itemName, metadata, strict)
    return ak47_inventory:GetItem(source, itemName, metadata or nil, strict or false) or {}
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata? table Item metadata (unused)
---@return table
Inventory.GetItemBySlot = function(source, slot, metadata)
    local items = ak47_inventory:GetInventoryItems(source) or {}
    local direct = items[slot]
    if direct then
        return direct
    end
    for _, item in pairs(items) do
        if item and item.slot == slot then
            return item
        end
    end
    return {}
end

---@param source number Source player ID
---@return table
Inventory.GetPlayerInventory = function(source)
    return ak47_inventory:GetInventoryItems(source) or {}
end

---@param source number Source player ID
Inventory.ClearPlayerInventory = function(source)
    ak47_inventory:ClearInventory(source, source)
end

---@param source number Source player ID (unused)
---@param slot number Item slot (unused)
---@param metadata table Item metadata (unused)
Inventory.SetMetadata = function(source, slot, metadata)
    ak47_inventory:SetItemInfo(source, slot, metadata)
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
    local data = { type = 'stash', label = label, slots = slots or 50, maxWeight = maxWeight or 50000 }
    ak47_inventory:CreateInventory(stashId, data)
end

---@param source number Source player ID
---@param _type string 'stash', 'trunk', 'glovebox' (unused)
---@param stashId string | number Stash ID
Inventory.OpenStash = function(source, _type, stashId)
    ak47_inventory:OpenInventory(source, stashId)
end

---@param stashId string | number Stash ID
---@param items table {item, count, metadata}
---@return boolean
Inventory.AddStashItems = function(stashId, items)
    if type(items) ~= 'table' then return false end
    local success = false
    for _, v in pairs(items) do
        if type(v) ~= 'table' then print('ak47_inventory:AddStashItems - item is not a table') goto continue end
        if not v.item or not (v.count or v.amount) then print('ak47_inventory:AddStashItems - item or count/amount is missing') goto continue end
        success = ak47_inventory:AddItem(stashId, v.item, v.count or v.amount, nil, v.metadata or v.info or nil) or success
        ::continue::
    end
    return success
end

---@param stashId string Stash ID
---@return table
Inventory.GetStashItems = function(stashId)
    return ak47_inventory:GetInventoryItems(stashId) or {}
end

---@param stashId string | number Stash ID
---@param _type? string Stash type (unused)
Inventory.ClearStash = function(stashId, _type)
    ak47_inventory:ClearInventory(stashId)
    if Inventory.Stashes[stashId] then
        Inventory.Stashes[stashId] = nil
    end
end

---@param itemName string Item name
---@return string
Inventory.GetItemLabel = function(itemName)
    return ak47_inventory:GetItemLabel(itemName)
end

---@param itemName? string Item name (optional)
---@return table
Inventory.Items = function(itemName)
    return ak47_inventory:Items(itemName)
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
