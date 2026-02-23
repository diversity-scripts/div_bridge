local origen_inventory = exports.origen_inventory

return {
    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param metadata? table Item info (optional)
    ---@param slot? number Item slot (optional)
    ---@param ignoreWeight? boolean Ignore weight (optional)
    ---@return boolean
    AddItem = function(source, itemName, itemCount, metadata, slot, ignoreWeight)
        local success, _ = origen_inventory:addItem(source, itemName, itemCount or 1, metadata or nil, slot or nil, ignoreWeight or false)
        return success
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param slot? number Item slot (optional)
    ---@param metadata? table Item info (optional)
    ---@param ignoreTotal? boolean Ignore total count (optional)
    ---@return boolean
    RemoveItem = function(source, itemName, itemCount, slot, metadata, ignoreTotal)
        local success, _ = origen_inventory:removeItem(source, itemName, itemCount or 1, metadata or nil, slot or nil, ignoreTotal or false)
        return success
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@return number
    GetItemCount = function(source, itemName)
        local totalCount = origen_inventory:getItemCount(source, itemName)
        return totalCount and tonumber(totalCount) or 0
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@return boolean
    HasItem = function(source, itemName, itemCount)
        local totalCount = origen_inventory:getItemCount(source, itemName)
        return totalCount and totalCount >= (itemCount or 1) or false
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param metadata? table Item info (optional)
    ---@return table
    GetItemData = function(source, itemName, metadata)
        return origen_inventory:getItem(source, itemName, metadata or nil, false) or {}
    end,

    ---@param source number Source player ID
    ---@return table
    GetPlayerInventory = function(source)
        return origen_inventory:getInventory(source) or {}
    end,

    ---@param source number Source player ID
    ---@param itemName string Item name
    ---@param itemCount number Item count
    ---@param metadata? table Item info (optional)
    ---@return boolean
    CanCarryItem = function(source, itemName, itemCount, metadata)
        return origen_inventory:canCarryItem(source, itemName, itemCount or 1, metadata or nil)
    end,

    ---@param source number Source player ID
    ClearInventory = function(source)
        origen_inventory:ClearInventory(source)
    end,

    ---@param source number Source player ID
    ---@param stashId string | number Stash ID
    ---@param label string Stash label
    ---@param slots? number Stash slots (optional)
    ---@param maxWeight? number Stash max weight (optional)
    OpenStash = function(source, stashId, label, slots, maxWeight)
        local data = {label = label, slots = slots, weight = maxWeight}
        origen_inventory:registerStash(stashId, data)
        origen_inventory:OpenInventory(source, 'stash', stashId)
    end,

    ---@param stashId string Stash ID
    ---@return table
    GetStashItems = function(stashId)
        return origen_inventory:getInventory(stashId, 'stash') or {}
    end,

    ---@param itemName string Item name
    ---@return string
    GetItemLabel = function(itemName)
        return origen_inventory:getItemLabel(itemName) or itemName
    end,
}