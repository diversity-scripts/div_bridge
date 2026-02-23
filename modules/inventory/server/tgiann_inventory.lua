local tgiann_inventory = exports['tgiann-inventory']

return {
    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param metadata? table Item info (optional)
    ---@param slot? number Item slot (optional)
    AddItem = function(source, itemName, itemCount, metadata, slot)
        tgiann_inventory:AddItem(source, itemName, itemCount or 1, slot or nil, metadata or nil, false)
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param slot? number Item slot (optional)
    ---@param metadata? table Item info (optional)
    RemoveItem = function(source, itemName, itemCount, slot, metadata)
        tgiann_inventory:RemoveItem(source, itemName, itemCount or 1, slot or nil, metadata or nil)
    end,

    ---@param source number Source player ID
    ---@param items string | string[] Item name
    ---@return number
    GetItemCount = function(source, items)
        return tgiann_inventory:GetItemCount(source, items) or 0
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@return boolean
    HasItem = function(source, itemName, itemCount)
        return tgiann_inventory:HasItem(source, itemName, itemCount)
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param metadata? table Item metadata (optional)
    ---@return table
    GetItemData = function(source, itemName, metadata)
        return tgiann_inventory:GetItemByName(source, itemName, metadata or nil) or {}
    end,

    ---@param source number Source player ID
    ---@return table
    GetPlayerInventory = function(source)
        return tgiann_inventory:GetPlayerItems(source) or {}
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@return boolean
    CanCarryItem = function(source, itemName, itemCount)
        return tgiann_inventory:CanCarryItem(source, itemName, itemCount or 1)
    end,

    ---@param source number Source player ID
    ClearInventory = function(source)
        tgiann_inventory:ClearInventory(source)
    end,

    ---@param source number Source player ID
    ---@param stashId string | number Stash ID
    ---@param label string Stash label
    ---@param slots? number Stash slots (optional)
    ---@param maxWeight? number Stash max weight (optional)
    OpenStash = function(source, stashId, label, slots, maxWeight)
        tgiann_inventory:RegisterStash(stashId, label, slots, maxWeight)
        tgiann_inventory:ForceOpenInventory(source, 'stash', stashId)
    end,

    ---@param stashId string Stash ID
    ---@return table
    GetStashItems = function(stashId)
        -- return tgiann_inventory:GetStashItems(stashId) or {}
    end,

    ---@param itemName string Item name
    ---@return string
    GetItemlabel = function(itemName)
        return tgiann_inventory:GetItemLabel(itemName) or itemName
    end,
}