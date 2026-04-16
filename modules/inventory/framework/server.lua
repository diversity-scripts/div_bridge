local Inventory = {}

local function getFramework()
    local framework = Bridge.Framework
    if type(framework) ~= 'table' then
        error('Inventory: Bridge.Framework failed to load or is invalid. Please check your config.')
    end
    return framework
end

local framework = getFramework()

---@return string
function Inventory.GetResourceName()
    return 'framework'
end

---@param source number
---@param itemName string
---@param itemCount number
---@param metadata? table
---@param slot? number
---@return boolean
Inventory.AddItem = function(source, itemName, itemCount, metadata, slot)
    assert(framework.AddItem, 'Your framework does not provide a server-side "AddItem" function.')
    return framework:AddItem(source, itemName, itemCount, metadata, slot) or false
end

---@param source number
---@param itemName string
---@param itemCount number
---@param metadata? table
---@param slot? number
---@return boolean
Inventory.RemoveItem = function(source, itemName, itemCount, metadata, slot)
    assert(framework.RemoveItem, 'Your framework does not provide a server-side "RemoveItem" function.')
    return framework:RemoveItem(source, itemName, itemCount, metadata, slot) or false
end

---@param source number
---@param itemName string
---@param itemCount number
---@param metadata? table
---@return boolean
Inventory.CanCarryItem = function(source, itemName, itemCount, metadata)
    assert(framework.CanCarryItem, 'Your framework does not provide a server-side "CanCarryItem" function.')
    return framework:CanCarryItem(source, itemName, itemCount, metadata) or false
end

---@param source number
---@param items string | string[]
---@return number
Inventory.GetItemCount = function(source, items)
    assert(framework.GetItemCount, 'Your framework does not provide a server-side "GetItemCount" function.')
    return framework:GetItemCount(source, items) or 0
end

---@param source number
---@param items string | string[]
---@param itemCount number
---@return boolean
Inventory.HasItem = function(source, items, itemCount)
    assert(framework.HasItem, 'Your framework does not provide a server-side "HasItem" function.')
    return framework:HasItem(source, items, itemCount) or false
end

---@param source number
---@param itemName string
---@param metadata? table
---@param slot? number
---@return table
Inventory.GetItemByName = function(source, itemName, metadata, slot)
    assert(framework.GetItemByName, 'Your framework does not provide a server-side "GetItemByName" function.')
    return framework:GetItemByName(source, itemName, metadata, slot) or {}
end

---@param source number
---@param slot number
---@return table
Inventory.GetItemBySlot = function(source, slot)
    assert(framework.GetItemBySlot, 'Your framework does not provide a server-side "GetItemBySlot" function.')
    return framework:GetItemBySlot(source, slot) or {}
end

---@param source number
---@return table
Inventory.GetPlayerInventory = function(source)
    assert(framework.GetPlayerInventory, 'Your framework does not provide a server-side "GetPlayerInventory" function.')
    return framework:GetPlayerInventory(source) or {}
end

---@param source number
Inventory.ClearPlayerInventory = function(source)
    local fn = framework.ClearPlayerInventory or framework.ClearInventory
    assert(fn, 'Your framework does not provide a server-side "ClearPlayerInventory" function.')
    fn(source)
end

---@param source number
---@param slot number
---@param metadata table
Inventory.SetMetadata = function(source, slot, metadata)
    assert(framework.SetMetadata, 'Your framework does not provide a server-side "SetMetadata" function.')
    framework:SetMetadata(source, slot, metadata)
end

---@param stashId string | number
---@param label string
---@param slots? number
---@param maxWeight? number
---@param owner? string | boolean
---@param groups? table
---@param coords? vector3
Inventory.RegisterStash = function(stashId, label, slots, maxWeight, owner, groups, coords)
    assert(framework.RegisterStash, 'Your framework does not provide a server-side "RegisterStash" function.')
    framework:RegisterStash(stashId, label, slots, maxWeight, owner, groups, coords)
end

---@param source number
---@param _type string
---@param stashId string | number
Inventory.OpenStash = function(source, _type, stashId)
    assert(framework.OpenStash, 'Your framework does not provide a server-side "OpenStash" function.')
    framework:OpenStash(source, _type, stashId)
end

---@param stashId string | number
---@param items table
---@return boolean
Inventory.AddStashItems = function(stashId, items)
    assert(framework.AddStashItems, 'Your framework does not provide a server-side "AddStashItems" function.')
    return framework:AddStashItems(stashId, items) or false
end

---@param stashId string | number
---@return table
Inventory.GetStashItems = function(stashId)
    assert(framework.GetStashItems, 'Your framework does not provide a server-side "GetStashItems" function.')
    return framework:GetStashItems(stashId) or {}
end

---@param stashId string | number
---@param _type? string
Inventory.ClearStash = function(stashId, _type)
    assert(framework.ClearStash, 'Your framework does not provide a server-side "ClearStash" function.')
    framework:ClearStash(stashId, _type)
end

---@param itemName string
---@return string
Inventory.GetItemLabel = function(itemName)
    assert(framework.GetItemLabel, 'Your framework does not provide a server-side "GetItemLabel" function.')
    return framework.GetItemLabel(itemName) or itemName
end

---@param itemName? string
---@return table
Inventory.Items = function(itemName)
    local fn = framework.Items or framework.GetItems
    assert(fn, 'Your framework does not provide a server-side "Items" function.')
    return fn(itemName) or {}
end

---@param itemName string Item name
---@return string
Inventory.GetImagePath = function(itemName)
    local pngPath = LoadResourceFile('origen_inventory', ('html/images/%s.png'):format(itemName))
    local webpPath = LoadResourceFile('origen_inventory', ('html/images/%s.webp'):format(itemName))
    local imagePath = pngPath and ('nui://origen_inventory/html/images/%s.png'):format(itemName) or webpPath and ('nui://ox_inventory/web/images/%s.webp'):format(itemName)
    return imagePath or ''
end

return Inventory
