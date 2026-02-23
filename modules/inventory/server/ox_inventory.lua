local ox_inventory = exports.ox_inventory
local stashes = {}

return {
    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param metadata? table Item metadata (optional)
    ---@param slot? number Item slot (optional)
    ---@return boolean
    AddItem = function(source, itemName, itemCount, metadata, slot)
        return ox_inventory:AddItem(source, itemName, itemCount or 1, metadata or nil, slot or nil) or false
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param metadata? table Item metadata (optional)
    ---@param slot? number Item slot (optional)
    ---@return boolean
    RemoveItem = function(source, itemName, itemCount, metadata, slot)
        return ox_inventory:RemoveItem(source, itemName, itemCount or 1, metadata or nil, slot or nil) or false
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param metadata? table Item metadata (optional)
    ---@return number
    GetItemCount = function(source, itemName, metadata)
        return ox_inventory:GetItemCount(source, itemName, metadata or nil) or 0
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param metadata? table Item metadata (optional)
    ---@return boolean
    HasItem = function(source, itemName, itemCount, metadata)
        local count = ox_inventory:GetItemCount(source, itemName, metadata or nil) or 0
        return count >= (itemCount or 1)
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param metadata? table Item metadata (optional)
    ---@return table
    GetItemData = function(source, itemName, metadata)
        return ox_inventory:GetItem(source, itemName, metadata or nil) or {}
    end,

    ---@param source number Source player ID
    ---@return table
    GetPlayerInventory = function(source)
        return ox_inventory:GetInventory(source) or {}
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param metadata? table Item metadata (optional)
    ---@return boolean
    CanCarryItem = function(source, itemName, itemCount, metadata)
        return ox_inventory:CanCarryItem(source, itemName, itemCount or 1, metadata or nil) or false
    end,

    ---@param source number Source player ID
    ClearInventory = function(source)
        ox_inventory:ClearInventory(source)
    end,

    ---@param source number Source player ID
    ---@param stashId string | number Stash ID
    ---@param label string Stash label
    ---@param slots? number Stash slots (optional)
    ---@param maxWeight? number Stash max weight (optional)
    OpenStash = function(source, stashId, label, slots, maxWeight)
        if not stashes[stashId] then
            ox_inventory:RegisterStash(source, stashId, label, slots or 50, maxWeight, 100000)
            stashes[stashId] = true
        end

        TriggerClientEvent('ox_inventory:openInventory', source, 'stash', stashId)
    end,

    ---@param stashId string Stash ID
    ---@return table
    GetStashItems = function(stashId)
        if not stashes[stashId] then
            return {}
        end
        return ox_inventory:GetInventoryItems(stashId) or {}
    end,

    ---@param itemName string Item name
    ---@return string
    GetItemlabel = function(itemName)
        return ox_inventory:Items(itemName)?.label or itemName
    end,
}