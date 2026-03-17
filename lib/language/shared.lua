local Language = {}
local cache = {}

local function getLanguage()
    local lang = 'en'
    if Lib and Lib.config and type(Lib.config.Language) == 'string' and Lib.config.Language ~= '' then
        return Lib.config.Language
    end
    return lang
end

local function loadLocale(resource, key)
    local data = LoadResourceFile(resource, ('locales/%s.json'):format(key))
    if not data then return {} end

    local ok, decoded = pcall(json.decode, data)
    if not ok or type(decoded) ~= 'table' then return {} end

    return decoded
end

local function formatValue(str, ...)
    local n = select('#', ...)
    if n == 0 or type(str) ~= 'string' then return str end
    if n == 1 and type((...)) == 'table' then
        local params = ...
        -- named placeholders: {name}
        str = (str:gsub('{([%w_]+)}', function(k)
            local v = params[k]
            if v == nil then return '{' .. k .. '}' end
            return tostring(v)
        end))
        -- positional placeholders: {1}, {2}, ...
        str = (str:gsub('{(%d+)}', function(i)
            i = tonumber(i)
            local v = params[i]
            if v == nil then return '{' .. i .. '}' end
            return tostring(v)
        end))
        return str
    end
    -- printf-style placeholders using string.format; guard errors
    local ok, out = pcall(string.format, str, ...)
    if ok then return out end
    return str
end

---@param key string Locale key or dotted path
---@param ... any Optional format arguments
---@return any
Language.Locale = function(key, ...)
    local res = GetCurrentResourceName()
    local lang = getLanguage()

    local rcache = cache[res]
    if not rcache then
        rcache = {}
        cache[res] = rcache
    end

    local function getDict(locale)
        local d = rcache[locale]
        if not d then
            d = loadLocale(res, locale)
            rcache[locale] = d
        end
        return d
    end

    if key:find('%.') then
        local dict = getDict(lang)
        local value = dict
        for segment in key:gmatch('([^.]+)') do
            value = value and value[segment]
        end
        if value ~= nil then return formatValue(value, ...) end
        if lang ~= 'en' then
            local fallback = getDict('en')
            local v = fallback
            for segment in key:gmatch('([^.]+)') do
                v = v and v[segment]
            end
            if v ~= nil then return formatValue(v, ...) end
        end
        return formatValue(key, ...)
    end

    local dict = getDict(lang)
    local value = dict and dict[key]
    if value ~= nil then return formatValue(value, ...) end
    if lang ~= 'en' then
        local fallback = getDict('en')
        local v = fallback and fallback[key]
        if v ~= nil then return formatValue(v, ...) end
    end
    local other = getDict(key)
    if other and next(other) then return other end
    return formatValue(key, ...)
end

---@param key? string Locale key or dotted path
Language.Clear = function(key)
    if not key then
        cache = {}
        return
    end

    local res = GetCurrentResourceName()
    if key then
        local rcache = cache[res]
        if rcache then rcache[key] = nil end
        return
    end

    cache[res] = nil
end

return Language
