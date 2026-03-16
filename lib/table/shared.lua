local Table = {}

---Checks if a table contains a value
---@param t table The table to check
---@param value any The value to check for
---@return boolean
Table.Contains = function(tbl, value)
    if type(tbl) ~= 'table' then return error('Value must be a table') end
    if type(value) ~= 'table' then
        if rawget(tbl, value) ~= nil then
            return tbl[value] ~= nil and tbl[value] ~= false
        end
        for _, v in pairs(tbl) do
            if v == value then
                return true
            end
        end
        return false
    else
        if next(value) == nil then
            return true
        end
        local isSet = false
        for _, v in pairs(tbl) do
            if v == true then
                isSet = true
                break
            end
        end
        if isSet then
            for _, v in pairs(value) do
                if not tbl[v] then
                    return false
                end
            end
            return true
        end
        local set = {}
        for _, v in pairs(tbl) do
            set[v] = true
        end
        for _, v in pairs(value) do
            if not set[v] then
                return false
            end
        end
        return true
    end
end

---Checks if two tables match each other
---@param tbl1 table The first table to check
---@param tbl2 table The second table to check
---@return boolean
Table.Matches = function(tbl1, tbl2)
    if type(tbl1) ~= 'table' then return error('Value must be a table') end
    if type(tbl2) ~= 'table' then return error('Value must be a table') end

    local isSet = false
    for _, v in pairs(tbl1) do
        if v == true then
            isSet = true
            break
        end
    end

    if isSet then
        for _, v in pairs(tbl2) do
            if not tbl1[v] then
                return false
            end
        end
        return true
    end

    local set = {}
    for _, v in pairs(tbl1) do
        set[v] = true
    end
    for _, v in pairs(tbl2) do
        if not set[v] then
            return false
        end
    end

    return true
end

---Deep clones a table
---@param tbl table The table to clone
---@return table
local function deepClone(tbl)
    if type(tbl) ~= 'table' then return error('Value must be a table') end

    tbl = table.clone(tbl)
    for k, v in pairs(tbl) do
        tbl[k] = deepClone(v)
    end

    return tbl
end

---Merges two tables together
---@param tbl1 table The first table to merge
---@param tbl2 table The second table to merge
---@param override? boolean Whether to override existing keys in tbl1 with tbl2's values
---@return table
local function tableMerge(tbl1, tbl2, override)
    override = override == nil or override
    for k, v2 in pairs(tbl2) do
        local v1 = tbl1[k]
        local type1 = type(v1)
        local type2 = type(v2)

        if type1 == 'table' and type2 == 'table' then
            tableMerge(v1, v2, override)
        elseif override and (type1 == 'number' and type2 == 'number') then
            tbl1[k] = v1 + v2
        else
            tbl1[k] = v2
        end
    end

    return tbl1
end

Table.Merge = tableMerge
Table.DeepClone = deepClone

---Shuffles the elements of a table
---@param tbl table The table to shuffle
---@param copy? boolean Whether to create a copy of the table before shuffling
---@param rnd? function The random function to use for shuffling
---@return table
Table.Shuffle = function(tbl, copy, rnd)
    if type(tbl) ~= 'table' then return error('Value must be a table') end

    local rng = rnd or math.random
    local arr = tbl
    if copy == true then
        arr = {}
        for i, v in ipairs(tbl) do
            arr[i] = v
        end
    end

    local len = #arr
    for i = len, 2, -1 do
        local j = rng(i)
        arr[i], arr[j] = arr[j], arr[i]
    end

    return arr
end

---Maps the elements of a table to a new table
---@param tbl table The table to map
---@param cb function(value: any, key: any): any The callback function to map the elements
---@return table
Table.Map = function(tbl, cb)
    if type(tbl) ~= 'table' then return error('Value must be a table') end
    if type(cb) ~= 'function' then return error('Callback must be a function') end

    local newTbl = {}
    for k, v in pairs(tbl) do
        newTbl[k] = cb(v, k)
    end

    return newTbl
end

---Counts the number of elements in a table
---@param tbl table The table to count
---@return number
Table.Count = function(tbl)
    if type(tbl) ~= 'table' then return error('Value must be a table') end

    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end

    return count
end

return Table
