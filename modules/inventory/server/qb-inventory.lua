local qb_inventory = exports['qb-inventory']

return {
    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param info? table Item info (optional)
    ---@param slot? number Item slot (optional)
    ---@return boolean
    AddItem = function(source, itemName, itemCount, info, slot)
        return qb_inventory:AddItem(source, itemName, itemCount or 1, slot or false, info or false)
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param slot? number Item slot (optional)
    ---@return boolean
    RemoveItem = function(source, itemName, itemCount, slot)
        return qb_inventory:RemoveItem(source, itemName, itemCount or 1, slot or false)
    end,

    ---@param source number Source player ID
    ---@param items string | string[] Item names
    ---@return number
    GetItemCount = function(source, items)
        return qb_inventory:GetItemCount(source, items) or 0
    end,

    ---@param source number Source player ID
    ---@param items string | string[] Item names
    ---@param itemCount number Item count
    ---@return boolean
    HasItem = function(source, items, itemCount)
        return qb_inventory:HasItem(source, items, itemCount or 1)
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@return table
    GetItemData = function(source, itemName)
        return qb_inventory:GetItemByName(source, itemName) or {}
    end,

    ---@param source number Source player ID
    ---@return table
    GetPlayerInventory = function(source)
        return qb_inventory:GetInventory(source) or {}
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@return boolean
    CanCarryItem = function(source, itemName, itemCount)
        local canAdd, _ = qb_inventory:CanAddItem(source, itemName, itemCount or 1)
        return canAdd
    end,

    ---@param source number Source player ID
    ClearInventory = function(source)
        qb_inventory:ClearInventory(source)
    end,

    ---@param source number Source player ID
    ---@param stashId string | number Stash ID
    ---@param label string Stash label
    ---@param slots? number Stash slots (optional)
    ---@param maxWeight? number Stash max weight (optional)
    OpenStash = function(source, stashId, label, slots, maxWeight)
        local data = { label = label, maxweight = maxWeight, slots = slots }
        qb_inventory:OpenInventory(source, stashId, data)
    end,

    ---@param stashId string Stash ID
    ---@return table
    GetStashItems = function(stashId)
        local invData = qb_inventory:GetInventory(stashId)
        if invData == nil or invData == {} then
            return {}
        end

        return invData.items
    end,

    ---@param itemName string Item name
    ---@return string
    GetItemlabel = function(itemName)
        return itemName
    end,
}