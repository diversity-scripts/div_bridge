local codem_inventory = exports['codem-inventory']
local Inventory = {}

---@return string
Inventory.GetResourceName = function()
    return 'codem-inventory'
end

---@param itemName string Item name
---@return number
Inventory.GetItemCount = function(itemName)
    Bridge.debugPrint('Checking item count for:', itemName)
    local inventory = codem_inventory:getUserInventory() or {}
    local count = 0
    for _, item in pairs(inventory) do
        if item.name == itemName then
            count = count + (item.amount or item.count or 1)
        end
    end
    Bridge.debugPrint('Found count for', itemName, ':', count)
    return count
end

---@param itemName string Item name
---@param itemCount number Item count
---@return boolean
Inventory.HasItem = function(itemName, itemCount)
    local count = Inventory.GetItemCount(itemName)
    return count >= (itemCount or 1)
end

---@return table
Inventory.GetPlayerInventory = function()
    return codem_inventory:getUserInventory() or {}
end

return Inventory
