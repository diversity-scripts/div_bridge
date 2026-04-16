local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'none'
end

---@param itemName string Item name
---@return number
Inventory.GetItemCount = function(itemName)
    return 0
end

---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(itemName, itemCount)
    return false
end

---@return table
Inventory.GetPlayerInventory = function()
    return {}
end

---@param itemName string Item name
---@return string
Inventory.GetImagePath = function(itemName)
    return ''
end

return Inventory
