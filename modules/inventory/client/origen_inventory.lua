local origen_inventory = exports.origen_inventory

return {
    ---@param itemName string Item name
    ---@param metadata? table Item metadata
    ---@return number
    GetItemCount = function(itemName, metadata)
        return origen_inventory:Search('count', itemName, metadata or nil) or 0
    end,

    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@return boolean
    HasItem = function(itemName, itemCount)
        local result = origen_inventory:HasItem(itemName) or 0
        return result >= (itemCount or 1)
    end,

    ---@return table
    GetPlayerInventory = function()
        return origen_inventory:GetInventory() or {}
    end,
}