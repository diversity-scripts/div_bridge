local Ids = {}

local seeded = false
local function ensureSeed()
    if not seeded then
        local base = (type(os) == 'table' and type(os.time) == 'function') and os.time() or 0
        local gt = type(GetCloudTimeAsInt) == 'function' and GetCloudTimeAsInt() or (type(GetGameTimer) == 'function' and GetGameTimer() or 0)
        math.randomseed(base + gt)
        seeded = true
    end
end

local function randomChar(pattern)
    if pattern and #pattern > 0 then
        local idx = math.random(1, #pattern)
        return pattern:sub(idx, idx)
    end
    if math.random(1, 2) == 1 then
        return string.char(math.random(65, 90))
    else
        return tostring(math.random(0, 9))
    end
end

---@param tbl? table | nil Ids to check against must be the key to the tables value (optional)
---@param len? number | nil Defaults to 8 (optional)
---@param pattern? string | nil Defaults to alphanumeric (optional)
---@return string
Ids.CreateUniqueId = function(tbl, len, pattern)
    tbl = tbl or {}
    len = len or 8
    ensureSeed()

    local chars = {}
    for i = 1, len do
        chars[i] = randomChar(pattern)
    end

    local id = table.concat(chars)

    while tbl[id] do
        for i = 1, len do
            chars[i] = randomChar(pattern)
        end
        id = table.concat(chars)
    end

    return id
end

return Ids
