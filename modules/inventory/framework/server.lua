local Inventory = {}

---@return string
function Inventory.GetResourceName()
    return 'framework'
end

local function getFramework()
    local framework = Bridge.Framework
    if type(framework) ~= 'table' then
        error('Bridge.Framework failed to load or is invalid. Please check your config.')
    end
    return framework
end

---@param source number
---@param itemName string
---@param itemCount number
---@param metadata? table
---@param slot? number
---@return boolean
function Inventory.AddItem(source, itemName, itemCount, metadata, slot)
    local framework = getFramework()
    assert(framework.AddItem, 'Your framework does not provide "AddItem" function.')
    return framework:AddItem(source, itemName, itemCount, metadata, slot) or false
end

---@param source number
---@param itemName string
---@param itemCount number
---@param metadata? table
---@param slot? number
---@return boolean
function Inventory.RemoveItem(source, itemName, itemCount, metadata, slot)
    local framework = getFramework()
    assert(framework.RemoveItem, 'Your framework does not provide "RemoveItem" function.')
    return framework:RemoveItem(source, itemName, itemCount, metadata, slot) or false
end

---@param source number
---@param itemName string
---@param itemCount number
---@param metadata? table
---@return boolean
function Inventory.CanCarryItem(source, itemName, itemCount, metadata)
    local framework = getFramework()
    assert(framework.CanCarryItem, 'Your framework does not provide "CanCarryItem" function.')
    return framework:CanCarryItem(source, itemName, itemCount, metadata) or false
end

---@param source number
---@param items string | string[]
---@return number
function Inventory.GetItemCount(source, items)
    local framework = getFramework()
    assert(framework.GetItemCount, 'Your framework does not provide "GetItemCount" function.')
    return framework:GetItemCount(source, items) or 0
end

---@param source number
---@param items string | string[]
---@param itemCount number
---@return boolean
function Inventory.HasItem(source, items, itemCount)
    local framework = getFramework()
    assert(framework.HasItem, 'Your framework does not provide "HasItem" function.')
    return framework:HasItem(source, items, itemCount) or false
end

---@param source number
---@param itemName string
---@param metadata? table
---@param slot? number
---@return table
function Inventory.GetItemByName(source, itemName, metadata, slot)
    local framework = getFramework()
    assert(framework.GetItemByName, 'Your framework does not provide "GetItemByName" function.')
    return framework:GetItemByName(source, itemName, metadata, slot) or {}
end

---@param source number
---@param slot number
---@return table
function Inventory.GetItemBySlot(source, slot)
    local framework = getFramework()
    assert(framework.GetItemBySlot, 'Your framework does not provide "GetItemBySlot" function.')
    return framework:GetItemBySlot(source, slot) or {}
end

---@param source number
---@return table
function Inventory.GetPlayerInventory(source)
    local framework = getFramework()
    assert(framework.GetPlayerInventory, 'Your framework does not provide "GetPlayerInventory" function.')
    return framework:GetPlayerInventory(source) or {}
end

---@param source number
function Inventory.ClearPlayerInventory(source)
    local framework = getFramework()
    local fn = framework.ClearPlayerInventory or framework.ClearInventory
    assert(fn, 'Your framework does not provide "ClearPlayerInventory" function.')
    fn(source)
end

---@param source number
---@param slot number
---@param metadata table
function Inventory.SetMetadata(source, slot, metadata)
    local framework = getFramework()
    assert(framework.SetMetadata, 'Your framework does not provide "SetMetadata" function.')
    framework:SetMetadata(source, slot, metadata)
end

---@param stashId string | number
---@param label string
---@param slots? number
---@param maxWeight? number
---@param owner? string | boolean
---@param groups? table
---@param coords? vector3
function Inventory.RegisterStash(stashId, label, slots, maxWeight, owner, groups, coords)
    local framework = getFramework()
    assert(framework.RegisterStash, 'Your framework does not provide "RegisterStash" function.')
    framework:RegisterStash(stashId, label, slots, maxWeight, owner, groups, coords)
end

---@param source number
---@param _type string
---@param stashId string | number
function Inventory.OpenStash(source, _type, stashId)
    local framework = getFramework()
    assert(framework.OpenStash, 'Your framework does not provide "OpenStash" function.')
    framework:OpenStash(source, _type, stashId)
end

---@param stashId string | number
---@param items table
---@return boolean
function Inventory.AddStashItems(stashId, items)
    local framework = getFramework()
    assert(framework.AddStashItems, 'Your framework does not provide "AddStashItems" function.')
    return framework:AddStashItems(stashId, items) or false
end

---@param stashId string | number
---@return table
function Inventory.GetStashItems(stashId)
    local framework = getFramework()
    assert(framework.GetStashItems, 'Your framework does not provide "GetStashItems" function.')
    return framework:GetStashItems(stashId) or {}
end

---@param stashId string | number
---@param _type? string
function Inventory.ClearStash(stashId, _type)
    local framework = getFramework()
    assert(framework.ClearStash, 'Your framework does not provide "ClearStash" function.')
    framework:ClearStash(stashId, _type)
end

---@param itemName string
---@return string
function Inventory.GetItemlabel(itemName)
    local framework = getFramework()
    assert(framework.GetItemlabel, 'Your framework does not provide "GetItemlabel" function.')
    return framework.GetItemLabel(itemName) or itemName
end

---@param itemName? string
---@return table
function Inventory.Items(itemName)
    local framework = getFramework()
    local fn = framework.Items or framework.GetItems
    assert(fn, 'Your framework does not provide "Items" function.')
    return fn(itemName) or {}
end

return Inventory
