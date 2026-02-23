local tgiann_inventory = exports['tgiann-inventory']

return {
    ---@param itemName string Item name
    ---@param metadata? table Item metadata (optional)
    ---@param strict? boolean Whether to strictly match metadata (optional)
    ---@return number
    GetItemCount = function(itemName, metadata, strict)
        return tgiann_inventory:GetItemCount(itemName, metadata or nil, strict or false) or 0
    end,

    ---@param items string | string[] Item name
    ---@param itemCount number Item count
    ---@return boolean
    HasItem = function(items, itemCount)
        return tgiann_inventory:HasItem(items, itemCount)
    end,

    ---@return table
    GetPlayerInventory = function()
        return tgiann_inventory:GetPlayerItems() or {}
    end,
}