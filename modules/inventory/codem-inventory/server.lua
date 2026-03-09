local codem_inventory = exports['codem-inventory']
local Inventory = {}
Inventory.Stashes = Inventory.Stashes or {}

---@return string
Inventory.GetResourceName = function()
    return 'codem-inventory'
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param info? table Item info (optional)
---@param slot? number Item slot (optional)
---@return boolean
Inventory.AddItem = function(source, itemName, itemCount, info, slot)
    return codem_inventory:AddItem(source, itemName, itemCount or 1, slot or nil, info or nil)
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param slot? number Item slot (optional)
---@return boolean
Inventory.RemoveItem = function(source, itemName, itemCount, slot)
    return codem_inventory:RemoveItem(source, itemName, itemCount or 1, slot or nil)
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.CanCarryItem = function(source, itemName, itemCount)
    return true, print('codem-inventory does not provide "CanCarryItem" function. Weight is handled in the "AddItem" function.')
end

---@param source number Source player ID
---@param itemName string Item name
---@return number
Inventory.GetItemCount = function(source, itemName)
    return codem_inventory:GetItemsTotalAmount(source, itemName) or 0
end

---@param source number Source player ID
---@param items string | string[] Item names
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(source, items, itemCount)
    return codem_inventory:HasItem(source, items, itemCount or 1)
end

---@param source number Source player ID
---@param itemName string Item name
---@param slot? number Item slot (optional)
---@return table
Inventory.GetItemByName = function(source, itemName, slot)
    return codem_inventory:GetItemByName(source, itemName, slot or nil) or {}
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata? table Item metadata (unused)
---@return table
Inventory.GetItemBySlot = function(source, slot, metadata)
    return codem_inventory:GetItemBySlot(source, slot) or {}
end

---@param identifier string Player identifier
---@param source number Source player ID
---@return table
Inventory.GetPlayerInventory = function(identifier, source)
    return codem_inventory:GetInventory(identifier, source) or {}
end

---@param source number Source player ID
Inventory.ClearPlayerInventory = function(source)
    codem_inventory:ClearInventory(source)
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata table Item metadata
Inventory.SetMetadata = function(source, slot, metadata)
    codem_inventory:SetItemMetadata(source, slot, metadata)
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
    Inventory.Stashes[stashId] = { stashId = stashId, label = label, slots = slots, maxWeight = maxWeight }
end

---@param source number Source player ID (unused)
---@param _type string 'stash', 'trunk', 'glovebox' (unused)
---@param stashId string | number Stash ID
Inventory.OpenStash = function(source, _type, stashId)
    if not Inventory.Stashes[stashId] then return end
    local stash = Inventory.Stashes[stashId]
    if not stash then return end
    -- This should probably work?
    TriggerEvent('codem-inventory:server:openstash', stashId, stash.slots, stash.maxWeight, stash.label)
end

---@param stashId string | number Stash ID
---@param items table {item, count, metadata}
---@return boolean
Inventory.AddStashItems = function(stashId, items)
    if type(items) ~= 'table' then return false end

    local payload = {}
    for _, v in pairs(items) do
        if type(v) ~= 'table' then goto continue end
        local name = v.item or v.name
        local amount = v.amount or v.count
        local info = v.info or v.metadata
        if not name or not amount then goto continue end
        payload[#payload + 1] = { item = name, amount = amount, info = info }
        ::continue::
    end

    if #payload == 0 then return false end

    codem_inventory:UpdateStash(stashId, payload)
    return true
end

---@param stashId string Stash ID
---@return table
Inventory.GetStashItems = function(stashId)
    return codem_inventory:GetStashItems(stashId) or {}
end

---@param stashId string | number Stash ID
---@param _type? string Stash type (unused)
Inventory.ClearStash = function(stashId, _type)
    codem_inventory:UpdateStash(stashId, {})
end

---@param itemName string Item name
---@return string
Inventory.GetItemlabel = function(itemName)
    return codem_inventory:GetItemLabel(itemName) or itemName
end

---@param itemName? string Item name (unused)
---@return table
Inventory.Items = function(itemName)
    return codem_inventory:GetItemList() or {}
end

return Inventory
