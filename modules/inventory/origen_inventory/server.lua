local origen_inventory = exports.origen_inventory
local Inventory = {}
Inventory.Stashes = Inventory.Stashes or {}

---@return string
Inventory.GetResourceName = function()
    return 'origen_inventory'
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item info (optional)
---@param slot? number Item slot (optional)
---@return boolean
Inventory.AddItem = function(source, itemName, itemCount, metadata, slot, ignoreWeight)
    local success, _ = origen_inventory:addItem(source, itemName, itemCount or 1, metadata or nil, slot or nil)
    return success
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item info (optional)
---@param slot? number Item slot (optional)
---@return boolean
Inventory.RemoveItem = function(source, itemName, itemCount, metadata, slot)
    local success, _ = origen_inventory:removeItem(source, itemName, itemCount or 1, metadata or nil, slot or nil)
    return success
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item info (optional)
---@return boolean
Inventory.CanCarryItem = function(source, itemName, itemCount, metadata)
    return origen_inventory:canCarryItem(source, itemName, itemCount or 1, metadata or nil)
end

---@param source number Source player ID
---@param itemName string Item name
---@return number
Inventory.GetItemCount = function(source, itemName)
    local totalCount = origen_inventory:getItemCount(source, itemName)
    return totalCount and tonumber(totalCount) or 0
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(source, itemName, itemCount)
    local totalCount = origen_inventory:getItemCount(source, itemName)
    return totalCount and totalCount >= (itemCount or 1) or false
end

---@param source number Source player ID
---@param itemName string Item name
---@param metadata? table Item info (optional)
---@return table
Inventory.GetItemByName = function(source, itemName, metadata)
    return origen_inventory:getItem(source, itemName, metadata or nil, false) or {}
end

---@param inventory string | number Inventory ID
---@param slot number Item slot
---@param metadata? table Item info (optional)
---@return table {weight, name, metadata, slot, label, count}
Inventory.GetItemBySlot = function(inventory, slot, metadata)
    return origen_inventory:getSlot(inventory, slot, metadata or nil) or {}
end

---@param source number Source player ID
---@return table
Inventory.GetPlayerInventory = function(source)
    return origen_inventory:getInventory(source) or {}
end

---@param source number Source player ID
Inventory.ClearPlayerInventory = function(source)
    origen_inventory:ClearInventory(source)
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata table Item metadata
Inventory.SetMetadata = function(source, slot, metadata)
    origen_inventory:setMetadata(source, slot, metadata)
end

---@param stashId string | number Stash ID
---@param label string Stash label
---@param slots? number Stash slots (optional)
---@param maxWeight? number Stash max weight (optional)
---@param owner? string | boolean Stash owner (optional)
---@param groups? string[] Stash groups (optional)
---@param coords? vector3 Stash coordinates (optional)
Inventory.RegisterStash = function(stashId, label, slots, weight, owner, groups, coords)
    if Inventory.Stashes[stashId] then return end
    Inventory.Stashes[stashId] = true
    origen_inventory:registerStash(stashId, label, slots or 50, weight or 100000, owner or nil, groups or nil, coords or nil)
end

---@param source number Source player ID
---@param _type string 'stash', 'trunk', 'glovebox'
---@param stashId string | number Stash ID
Inventory.OpenStash = function(source, _type, stashId)
    _type = _type or 'stash'
    origen_inventory:OpenInventory(source, _type, stashId)
end

---@param stashId string | number Stash ID
---@param items table {item, count, metadata}
---@return boolean
Inventory.AddStashItems = function(stashId, items)
    if type(items) ~= 'table' then return end
    local success = false
    for _, v in pairs(items) do
        if type(v) ~= 'table' then print('origen_inventory:AddStashItems - item is not a table') goto continue end
        if not v.item or not (v.count or v.amount) then print('origen_inventory:AddStashItems - item or count/amount is missing') goto continue end
        success = origen_inventory:addItem(stashId, v.item, v.count or v.amount, v.metadata or v.info or nil) or success
        ::continue::
    end
    return success
end

---@param stashId string Stash ID
---@return table
Inventory.GetStashItems = function(stashId)
    return origen_inventory:getInventory(stashId, 'stash') or {}
end

---@param stashId string | number Stash ID
---@param _type string 'stash', 'trunk', 'glovebox'
Inventory.ClearStash = function(stashId, _type)
    if type(stashId) ~= 'string' then return end
    local id = stashId
    if _type == 'trunk' then
        id = 'trunk_' .. id
    elseif _type == 'glovebox' then
        id = 'glovebox_' .. id
    elseif _type == 'stash' then
        id = 'stash_' .. id
    end

    local inv = origin:getInventory(id, _type)
    if not inv then return false end

    local indexed = inv.inventory
    for _, v in pairs(indexed) do
        if v.slot then
            origin:removeItem(id, v.name, v.amount, nil, v.slot)
        end
    end

    if Inventory.Stashes[stashId] then
        Inventory.Stashes[stashId] = nil
    end
end

---@param itemName string Item name
---@return string
Inventory.GetItemLabel = function(itemName)
    return origen_inventory:getItemLabel(itemName) or itemName
end

---@param itemName string Item name
---@return string
Inventory.GetItemlabel = function(itemName)
    return Inventory.GetItemLabel(itemName)
end
---@param itemName? string Item name (optional)
---@return table
Inventory.Items = function(itemName)
    return origen_inventory:Items(itemName)
end

return Inventory
