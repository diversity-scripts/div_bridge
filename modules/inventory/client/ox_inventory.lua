local ox_inventory = exports.ox_inventory

return {
    ---@param itemName string Item name
    ---@param metadata? table Item metadata (optional)
    ---@param strict? boolean Whether to strictly match metadata (optional)
    ---@return number
    GetItemCount = function(itemName, metadata, strict)
        return ox_inventory:GetItemCount(itemName, metadata or nil, strict or false) or 0
    end,

    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@return boolean
    HasItem = function(itemName, itemCount)
        local count = ox_inventory:GetItemCount(itemName) or 0
        return count >= (itemCount or 1)
    end,

    ---@return table
    GetPlayerInventory = function()
        return ox_inventory:GetPlayerItems() or {}
    end,
}