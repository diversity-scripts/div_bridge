local qs_inventory = exports['qs-inventory']

return {
    ---@param itemName string Item name
    ---@return number
    GetItemCount = function(itemName)
        return qs_inventory:Search(itemName) or 0
    end,

    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@return boolean
    HasItem = function(itemName, itemCount)
        local result = qs_inventory:Search(itemName) or 0
        return result >= (itemCount or 1)
    end,

    ---@return table
    GetPlayerInventory = function()
        return qs_inventory:getUserInventory() or {}
    end,
}