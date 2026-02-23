local qs_inventory = exports['qs-inventory']

return {
    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param metadata? table Item info (optional)
    ---@param slot? number Item slot (optional)
    AddItem = function(source, itemName, itemCount, metadata, slot)
        qs_inventory:AddItem(source, itemName, itemCount or 1, slot or nil, metadata or nil)
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param slot? number Item slot (optional)
    ---@param metadata? table Item info (optional)
    RemoveItem = function(source, itemName, itemCount, slot, metadata)
        qs_inventory:RemoveItem(source, itemName, itemCount or 1, slot or nil, metadata or nil)
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@return number
    GetItemCount = function(source, itemName)
        return qs_inventory:GetItemTotalAmount(source, itemName) or 0
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@return boolean
    HasItem = function(source, itemName, itemCount)
        local itemTotalAmount = qs_inventory:GetItemTotalAmount(source, itemName)
        return itemTotalAmount >= (itemCount or 1)
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@return table
    GetItemData = function(source, itemName)
        local inventory = qs_inventory:GetInventory(source)
        for _, item in pairs(inventory) do
            if item.name == itemName then
                return item
            end
        end

        return {}
    end,

    ---@param source number Source player ID
    ---@return table
    GetPlayerInventory = function(source)
        return qs_inventory:GetInventory(source) or {}
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@return boolean
    CanCarryItem = function(source, itemName, itemCount)
        return qs_inventory:CanCarryItem(source, itemName, itemCount or 1)
    end,

    ---@param source number Source player ID
    ClearInventory = function(source)
        qs_inventory:ClearInventory(source)
    end,

    ---@param source number Source player ID
    ---@param stashId string | number Stash ID
    ---@param slots? number Stash slots (optional)
    ---@param maxWeight? number Stash max weight (optional)
    OpenStash = function(source, stashId, slots, maxWeight)
        qs_inventory:RegisterStash(source, stashId, slots, maxWeight)
    end,

    ---@param stashId string Stash ID
    ---@return table
    GetStashItems = function(stashId)
        return qs_inventory:GetStashItems(stashId) or {}
    end,

    ---@param itemName string Item name
    ---@return string
    GetItemlabel = function(itemName)
        return qs_inventory:GetItemLabel(itemName) or itemName
    end,
}