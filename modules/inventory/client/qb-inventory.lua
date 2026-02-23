local qb_inventory = exports['qb-inventory']

return {
    ---@param itemName string Item name
    ---@return number
    GetItemCount = function(itemName)
        return qb_inventory:GetItemCount(itemName) or 0
    end,

    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@return boolean
    HasItem = function(itemName, itemCount)
        return qb_inventory:HasItem(itemName, itemCount)
    end,

    ---@return table
    GetPlayerInventory = function()
        -- return qb_inventory:GetPlayerItems() or {}
    end,
}