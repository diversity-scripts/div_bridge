local ox_inventory = exports.ox_inventory
local Inventory = {}
Inventory.Stashes = Inventory.Stashes or {}

---@return string
Inventory.GetResourceName = function()
    return 'ox_inventory'
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@param slot? number Item slot (optional)
---@return boolean
Inventory.AddItem = function(source, itemName, itemCount, metadata, slot)
    return ox_inventory:AddItem(source, itemName, itemCount or 1, metadata or nil, slot or nil) or false
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@param slot? number Item slot (optional)
---@return boolean
Inventory.RemoveItem = function(source, itemName, itemCount, metadata, slot)
    return ox_inventory:RemoveItem(source, itemName, itemCount or 1, metadata or nil, slot or nil) or false
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@return boolean
Inventory.CanCarryItem = function(source, itemName, itemCount, metadata)
    return ox_inventory:CanCarryItem(source, itemName, itemCount or 1, metadata or nil) or false
end

---@param source number Source player ID
---@param itemName string Item name
---@param metadata? table Item metadata (optional)
---@return number
Inventory.GetItemCount = function(source, itemName, metadata)
    return ox_inventory:GetItemCount(source, itemName, metadata or nil) or 0
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@return boolean
Inventory.HasItem = function(source, itemName, itemCount, metadata)
    local count = ox_inventory:GetItemCount(source, itemName, metadata or nil) or 0
    return count >= (itemCount or 1)
end

---@param source number Source player ID
---@param itemName string Item name
---@param metadata? table Item metadata (optional)
---@param strict? boolean Whether to strictly match metadata (unused)
---@return table
Inventory.GetItemByName = function(source, itemName, metadata)
    return ox_inventory:GetItem(source, itemName, metadata or nil) or {}
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata? table Item metadata (optional)
---@return table {weight, name, metadata, slot, label, count}
Inventory.GetItemBySlot = function(source, slot, metadata)
    return ox_inventory:GetSlot(source, slot, metadata or nil) or {}
end

---@param source number Source player ID
---@return table
Inventory.GetPlayerInventory = function(source)
    return ox_inventory:GetInventory(source) or {}
end

---@param source number Source player ID
Inventory.ClearPlayerInventory = function(source)
    ox_inventory:ClearInventory(source)
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata table Item metadata
Inventory.SetMetadata = function(source, slot, metadata)
    ox_inventory:SetMetadata(source, slot, metadata)
end

---@param stashId string | number Stash ID
---@param label string Stash label
---@param slots number Stash slots
---@param maxWeight number Stash max weight
---@param owner? string | boolean Stash owner (optional)
---@param groups? string[] Stash groups (optional)
---@param coords? vector3 Stash coordinates (optional)
Inventory.RegisterStash = function(stashId, label, slots, maxWeight, owner, groups, coords)
    if Inventory.Stashes[stashId] then return end
    Inventory.Stashes[stashId] = true
    ox_inventory:RegisterStash(stashId, label, slots or 50, maxWeight or 100000, owner or nil, groups or nil, coords or nil)
end

---@param source number Source player ID
---@param _type string 'stash', 'trunk', 'glovebox'
---@param stashId string | number Stash ID
Inventory.OpenStash = function(source, _type, stashId)
    _type = _type or 'stash'
    ox_inventory:forceOpenInventory(source, _type, stashId)
end

---@param stashId string | number Stash ID
---@param items table {item, count, metadata}
---@return boolean
Inventory.AddStashItems = function(stashId, items)
    if type(items) ~= 'table' then return false end
    local success = false
    for _, v in pairs(items) do
        if type(v) ~= 'table' then print('ox_inventory:AddStashItems - item is not a table') goto continue end
        if not v.item or not (v.count or v.amount) then print('ox_inventory:AddStashItems - item or count/amount is missing') goto continue end
        success = ox_inventory:AddItem(stashId, v.item, v.count or v.amount, v.metadata or v.info or nil) or success
        ::continue::
    end
    return success
end

---@param stashId string | number Stash ID
---@return table
Inventory.GetStashItems = function(stashId)
    return ox_inventory:GetInventoryItems(stashId) or {}
end

---@param stashId string | number Stash ID
---@param _type string 'stash', 'trunk', 'glovebox' (unused)
Inventory.ClearStash = function(stashId, _type)
    ox_inventory:ClearInventory(stashId)
    if Inventory.Stashes[stashId] then
        Inventory.Stashes[stashId] = nil
    end
end

---@param itemName string Item name
---@return string
Inventory.GetItemLabel = function(itemName)
    return ox_inventory:Items(itemName)?.label or itemName
end

---@param itemName? string Item name (optional)
---@return table
Inventory.Items = function(itemName)
    return ox_inventory:Items(itemName)
end

---@param itemName string Item name
---@return string
Inventory.GetImagePath = function(itemName)
    local pngPath = LoadResourceFile('ox_inventory', ('web/images/%s.png'):format(itemName))
    local webpPath = LoadResourceFile('ox_inventory', ('web/images/%s.webp'):format(itemName))
    local imagePath = pngPath and ('nui://ox_inventory/web/images/%s.png'):format(itemName) or webpPath and ('nui://ox_inventory/web/images/%s.webp'):format(itemName)
    return imagePath or ''
end

return Inventory
