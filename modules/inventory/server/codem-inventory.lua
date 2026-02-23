local codem_inventory = exports['codem-inventory']

return {
    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param info? table Item info (optional)
    ---@param slot? number Item slot (optional)
    ---@return boolean
    AddItem = function(source, itemName, itemCount, info, slot)
        return codem_inventory:AddItem(source, itemName, itemCount or 1, slot or nil, info or nil)
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param slot? number Item slot (optional)
    ---@return boolean
    RemoveItem = function(source, itemName, itemCount, slot)
        return codem_inventory:RemoveItem(source, itemName, itemCount or 1, slot or nil)
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@return number
    GetItemCount = function(source, itemName)
        return codem_inventory:GetItemsTotalAmount(source, itemName) or 0
    end,

    ---@param source number Source player ID
    ---@param items string | string[] Item names
    ---@param itemCount number Item count
    ---@return boolean
    HasItem = function(source, items, itemCount)
        return codem_inventory:HasItem(source, items, itemCount or 1)
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param slot? number Item slot (optional)
    ---@return table
    GetItemData = function(source, itemName, slot)
        return codem_inventory:GetItemByName(source, itemName, slot or nil) or {}
    end,

    ---@param identifier string Player identifier
    ---@param source number Source player ID
    ---@return table
    GetPlayerInventory = function(identifier, source)
        return codem_inventory:GetInventory(identifier, source) or {}
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@return boolean
    CanCarryItem = function(source, itemName, itemCount)
        -- local canAdd, _ = qb_inventory:CanAddItem(source, itemName, itemCount or 1)
        -- return canAdd
    end,

    ---@param source number Source player ID
    ClearInventory = function(source)
        codem_inventory:ClearInventory(source)
    end,

    ---@param source number Source player ID
    ---@param stashId string | number Stash ID
    ---@param label string Stash label
    ---@param slots? number Stash slots (optional)
    ---@param maxWeight? number Stash max weight (optional)
    OpenStash = function(source, stashId, label, slots, maxWeight)
        TriggerServerEvent('codem-inventory:server:openstash', stashId, slots, maxWeight, label)
    end,

    ---@param stashId string Stash ID
    ---@return table
    GetStashItems = function(stashId)
        return codem_inventory:GetStashItems(stashId) or {}
    end,

    ---@param itemName string Item name
    ---@return string
    GetItemlabel = function(itemName)
        return codem_inventory:GetItemLabel(itemName) or itemName
    end,
}