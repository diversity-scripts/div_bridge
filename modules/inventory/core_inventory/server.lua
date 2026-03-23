local core_inventory = exports.core_inventory
local Inventory = {}
Inventory.Stashes = Inventory.Stashes or {}

---@return string
Inventory.GetResourceName = function()
    return 'core_inventory'
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@param slot? number Item slot (unused)
---@return boolean
Inventory.AddItem = function(source, itemName, itemCount, metadata, slot)
    local success = core_inventory:addItem(source, itemName, itemCount or 1, metadata or nil)
    if not success then return false end
    return success or false
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@param slot? number Item slot (optional)
---@return boolean
Inventory.RemoveItem = function(source, itemName, itemCount, metadata, slot)
    if not slot and metadata then
        local inv = Inventory.GetPlayerInventory(source)
        if not inv then return false end
        for _, v in pairs(inv) do
            if v.name == itemName and v.metadata == metadata then
                slot = v.id or v.slot
                break
            end
        end
    end

    if slot then
        local identifier = Bridge.Framework:GetPlayerIdentifier(source)
        if not identifier then return false end

        local framework = Bridge.Framework:GetFrameworkName()
        if framework == 'es_extended' then
            identifier = string.gsub(identifier, ':', '')
        end

        local inventoryName = 'content-' .. identifier
        return core_inventory:removeItemExact(inventoryName, slot, itemCount or 1)
    end

    core_inventory:removeItem(source, itemName, itemCount or 1)
    return true
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@return boolean
Inventory.CanCarryItem = function(source, itemName, itemCount, metadata)
    return core_inventory:canCarry(source, itemName, itemCount, metadata or nil)
end

---@param source number Source player ID
---@param items string | string[] Item names
---@return number
Inventory.GetItemCount = function(source, items)
    return core_inventory:getItemCount(source, items) or 0
end

---@param source number Source player ID
---@param items string | string[] Item names
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(source, items, itemCount)
    return core_inventory:hasItem(source, items, itemCount or 1)
end

---@param source number Source player ID
---@param itemName string Item name
---@return table
Inventory.GetItemByName = function(source, itemName)
    return core_inventory:getItem(source, itemName) or {}
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata? table Item metadata (unused)
---@return table
Inventory.GetItemBySlot = function(source, slot, metadata)
    return core_inventory:getItemBySlot(source, slot) or {}
end

---@param source number Source player ID
---@return table
Inventory.GetPlayerInventory = function(source)
    return core_inventory:getInventory(source)
end

---@param source number Source player ID
Inventory.ClearPlayerInventory = function(source)
    core_inventory:clearInventory(source, source)
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata table Item metadata
Inventory.SetMetadata = function(source, slot, metadata)
    core_inventory:setMetadata(source, slot, metadata)
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

---@param source number Source player ID
---@param _type string 'stash', 'trunk', 'glovebox'
---@param stashId string | number Stash ID
Inventory.OpenStash = function(source, _type, stashId)
    _type = _type or 'stash'
    if not Inventory.Stashes[stashId] then return end
    local stash = Inventory.Stashes[stashId]
    if not stash then return end
    core_inventory:openInventory(source, stashId, _type, stash.slots or 30, stash.maxWeight or 50000, true, nil, false)
end

---@param stashId string | number Stash ID
---@param items table Items to add (unused)
---@return boolean
Inventory.AddStashItems = function(stashId, items)
    if type(items) ~= 'table' then return false end
    local success = false
    for _, v in pairs(items) do
        if type(v) ~= 'table' then print('core_inventory:AddStashItems - item is not a table') goto continue end
        if not v.item or not (v.count or v.amount) then print('core_inventory:AddStashItems - item or count/amount is missing') goto continue end
        success = core_inventory:addItem('stash-' .. stashId, v.item, v.count or v.amount, v.metadata or v.info or nil) or success
        ::continue::
    end
    return success
end

---@param stashId string Stash ID
---@return table
Inventory.GetStashItems = function(stashId)
    return core_inventory:getInventory('stash-' .. stashId) or {}
end

---@param stashId string | number Stash ID
---@param _type? string Stash type (unused)
Inventory.ClearStash = function(stashId, _type)
    core_inventory:clearInventory('stash-' .. stashId)
    if Inventory.Stashes[stashId] then
        Inventory.Stashes[stashId] = nil
    end
end

---@param itemName string Item name
---@return string
Inventory.GetItemLabel = function(itemName)
    local items = core_inventory:getItemsList()
    if items and items[itemName] then
        return items[itemName].label
    end
    return itemName
end

---@param itemName? string Item name (unused)
---@return table
Inventory.Items = function(itemName)
    return core_inventory:getItemsList() or {}
end

---@param itemName string Item name
---@return string
Inventory.GetImagePath = function(itemName)
    local pngPath = LoadResourceFile('core_inventory', ('html/img/%s.png'):format(itemName))
    local webpPath = LoadResourceFile('core_inventory', ('html/img/%s.webp'):format(itemName))
    local imagePath = pngPath and ('nui://core_inventory/html/img/%s.png'):format(itemName) or webpPath and ('nui://core_inventory/html/img/%s.webp'):format(itemName)
    return imagePath or ''
end

return Inventory
