local jaksam_inventory = exports['jaksam_inventory']
local Inventory = {}
Inventory.Stashes = Inventory.Stashes or {}

---@return string
Inventory.GetResourceName = function()
    return 'jaksam_inventory'
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@param slot? number Item slot (optional)
---@return boolean
Inventory.AddItem = function(source, itemName, itemCount, metadata, slot)
    return jaksam_inventory:addItem(source, itemName, itemCount or 1, metadata or nil, slot or nil)
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@param slot? number Item slot (optional)
---@return boolean
Inventory.RemoveItem = function(source, itemName, itemCount, metadata, slot)
    return jaksam_inventory:removeItem(source, itemName, itemCount or 1, metadata or nil, slot or nil)
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (unused)
---@return boolean
Inventory.CanCarryItem = function(source, itemName, itemCount, metadata)
    return jaksam_inventory:canCarryItem(source, itemName, itemCount or 1)
end

---@param source number Source player ID
---@param itemName string Item name
---@return number
Inventory.GetItemCount = function(source, itemName)
    return jaksam_inventory:getTotalItemAmount(source, itemName, nil, true) or 0
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(source, itemName, itemCount)
    return jaksam_inventory:hasItem(source, itemName, itemCount or 1) or false
end

---@param source number Source player ID
---@return table
Inventory.GetPlayerInventory = function(source)
    return jaksam_inventory:getInventory(source) or {}
end

---@param source number Source player ID
Inventory.ClearPlayerInventory = function(source)
    jaksam_inventory:clearInventory(source)
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata table Item metadata
Inventory.SetMetadata = function(source, slot, metadata)
    return jaksam_inventory:setItemMetadataInSlot(source, slot, metadata)
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
    
    local allowedJobs = nil
    if groups and type(groups) == 'table' then
        allowedJobs = {}
        for i = 1, #groups do
            allowedJobs[groups[i]] = true
        end
    end
    
    return jaksam_inventory:registerStash({ 
        id = stashId, 
        label = label, 
        maxSlots = slots, 
        maxWeight = maxWeight, 
        isPrivate = owner ~= nil and owner ~= false,
        allowedJobs = allowedJobs,
        coords = coords or nil 
    })
end

---@param source number Source player ID
---@param _type string 'stash', 'trunk', 'glovebox' (unused)
---@param stashId string | number Stash ID
Inventory.OpenStash = function(source, _type, stashId)
    if not Inventory.Stashes[stashId] then return end
    jaksam_inventory:forceOpenInventory(source, stashId)
end

---@param stashId string | number Stash ID
---@param items table {item, count, metadata}
---@return boolean
Inventory.AddStashItems = function(stashId, items)
    if type(items) ~= 'table' then return end
    local success = false
    for _, v in pairs(items) do
        if type(v) ~= 'table' then print('jaksam_inventory:AddStashItems - item is not a table') goto continue end
        if not v.item or not (v.count or v.amount) then print('jaksam_inventory:AddStashItems - item or count/amount is missing') goto continue end
        success = jaksam_inventory:addItem(stashId, v.item, v.count or v.amount, v.metadata or v.info or nil) or success
        ::continue::
    end
    return success
end

---@param stashId string | number Stash ID
---@return table
Inventory.GetStashItems = function(stashId)
    return jaksam_inventory:getInventory(stashId) or {}
end

---@param stashId string | number Stash ID
---@param _type string 'stash', 'trunk', 'glovebox' (unused)
Inventory.ClearStash = function(stashId, _type)
    local success = jaksam_inventory:clearInventory(stashId)

    if success and Inventory.Stashes[stashId] then
        Inventory.Stashes[stashId] = nil
    end

    return success
end

---@param itemName string Item name
---@return string
Inventory.GetItemLabel = function(itemName)
    return jaksam_inventory:getItemLabel(itemName) or itemName
end

---@param itemName? string Item name (optional)
---@return table
Inventory.Items = function(itemName)
    if itemName then
        return jaksam_inventory:getStaticItem(itemName) or {}
    end
    return jaksam_inventory:getStaticItemsList() or {}
end

---@param itemName string Item name
---@return string
Inventory.GetImagePath = function(itemName)
    return jaksam_inventory:getItemImagePath(itemName) or ''
end

return Inventory
