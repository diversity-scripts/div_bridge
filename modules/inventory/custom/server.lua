local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'none'
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@param slot? number Item slot (optional)
---@return boolean
Inventory.AddItem = function(source, itemName, itemCount, metadata, slot)
    return true
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@param slot? number Item slot (optional)
---@return boolean
Inventory.RemoveItem = function(source, itemName, itemCount, metadata, slot)
    return true
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@param metadata? table Item metadata (optional)
---@return boolean
Inventory.CanCarryItem = function(source, itemName, itemCount, metadata)
    return true
end

---@param source number Source player ID
---@param itemName string Item name
---@return number
Inventory.GetItemCount = function(source, itemName)
    return 0
end

---@param source number Source player ID
---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(source, itemName, itemCount)
    return false
end

---@param source number Source player ID
---@return table
Inventory.GetPlayerInventory = function(source)
    return {}
end

---@param source number Source player ID
Inventory.ClearPlayerInventory = function(source)
end

---@param source number Source player ID
---@param slot number Item slot
---@param metadata table Item metadata
Inventory.SetMetadata = function(source, slot, metadata)
end

---@param stashId string | number Stash ID
---@param label string Stash label
---@param slots number Stash slots
---@param maxWeight number Stash max weight
---@param owner? string | boolean Stash owner (optional)
---@param groups? string[] Stash groups (optional)
---@param coords? vector3 Stash coordinates (optional)
Inventory.RegisterStash = function(stashId, label, slots, maxWeight, owner, groups, coords)
end

---@param source number Source player ID
---@param _type string 'stash', 'trunk', 'glovebox'
---@param stashId string | number Stash ID
Inventory.OpenStash = function(source, _type, stashId)
end

---@param stashId string | number Stash ID
---@param items table {item, count, metadata}
---@return boolean
Inventory.AddStashItems = function(stashId, items)
    return true
end

---@param stashId string | number Stash ID
---@return table
Inventory.GetStashItems = function(stashId)
    return {}
end

---@param stashId string | number Stash ID
---@param _type string 'stash', 'trunk', 'glovebox' (unused)
Inventory.ClearStash = function(stashId, _type)
end

---@param itemName string Item name
---@return string
Inventory.GetItemLabel = function(itemName)
    return itemName
end

---@param itemName? string Item name (optional)
---@return table
Inventory.Items = function(itemName)
    return {}
end

---@param itemName string Item name
---@return string
Inventory.GetImagePath = function(itemName)
    return ''
end

return Inventory
