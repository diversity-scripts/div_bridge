local Math = {}

local function interpolateTable(start, finish, factor)
    local interp = math.interp
    local result = {}

    for k, v in pairs(start) do
        result[k] = interp(v, finish[k], factor)
    end

    return result
end

---Rounds a number to the specified number of decimal places.
---@param value number | string The number to round
---@param places? number | string The number of decimal places to round to (optional)
---@return number
Math.Round = function(value, places)
    if type(value) == 'string' then value = tonumber(value) end
    if type(value) ~= 'number' then error('Value must be a number') end

    if places then
        if type(places) == 'string' then places = tonumber(places) end
        if type(places) ~= 'number' then error('Places must be a number') end

        if places > 0 then
            local mult = 10 ^ (places or 0)
            return math.floor(value * mult + 0.5) / mult
        end
    end

    return math.floor(value + 0.5)
end

---Clamps a value between a minimum and maximum value.
---@param value number | string The value to clamp
---@param min number | string The minimum value
---@param max number | string The maximum value
---@return number
Math.Clamp = function(value, min, max)  -- credit https://love2d.org/forums/viewtopic.php?t=1856
    if type(value) == 'string' then value = tonumber(value) end
    if type(min) == 'string' then min = tonumber(min) end
    if type(max) == 'string' then max = tonumber(max) end
    if type(value) ~= 'number' then error('Value must be a number') end
    if type(min) ~= 'number' then error('Value must be a number') end
    if type(max) ~= 'number' then error('Value must be a number') end
    if min > max then min, max = max, min end
    if value < min then return min end
    if value > max then return max end
    return value
end

---Converts a number to a hex string
---@param n number | string The number to convert
---@param upper? boolean Whether to use uppercase letters
---@return string
Math.ToHex = function(n, upper)
    if type(n) == 'number' then n = tonumber(n) end
    if type(n) ~= 'number' then error('Value must be a number') end
    local formatString = ('0x%s'):format(upper and '%X' or '%x')
    return formatString:format(n)
end

---Converts a hex string to RGB values
---@param hex string The hex string to convert
---@return number r The red value (0-255)
---@return number g The green value (0-255)
---@return number b The blue value (0-255)
Math.HexToRGB = function(input)
    if type(input) ~= 'string' then error('Value must be a string') end
    local r, g, b = string.match(input, '([^#]+.)(..)(..)')
    return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
end

---Converts a hex string to RGBA values
---@param color string The hex string to convert
---@return number r The red value (0-255)
---@return number g The green value (0-255)
---@return number b The blue value (0-255)
---@return number a The alpha value (0-255)
Math.HexToRGBA = function(input)
    if type(input) ~= 'string' then error('Value must be a string') end
    local s = input:gsub('#', ''):upper()
    if #s == 3 then
        local r = tonumber(s:sub(1, 1) .. s:sub(1, 1), 16)
        local g = tonumber(s:sub(2, 2) .. s:sub(2, 2), 16)
        local b = tonumber(s:sub(3, 3) .. s:sub(3, 3), 16)
        return r, g, b, 255
    elseif #s == 4 then
        local r = tonumber(s:sub(1, 1) .. s:sub(1, 1), 16)
        local g = tonumber(s:sub(2, 2) .. s:sub(2, 2), 16)
        local b = tonumber(s:sub(3, 3) .. s:sub(3, 3), 16)
        local a = tonumber(s:sub(4, 4) .. s:sub(4, 4), 16)
        return r, g, b, a
    elseif #s == 6 then
        local r = tonumber(s:sub(1, 2), 16)
        local g = tonumber(s:sub(3, 4), 16)
        local b = tonumber(s:sub(5, 6), 16)
        return r, g, b, 255
    elseif #s == 8 then
        local r = tonumber(s:sub(1, 2), 16)
        local g = tonumber(s:sub(3, 4), 16)
        local b = tonumber(s:sub(5, 6), 16)
        local a = tonumber(s:sub(7, 8), 16)
        return r, g, b, a
    else
        error('Invalid hex color')
    end
end

---Converts a normalized vector3 to a rotation vector
---@param input vector3 The normalized vector3 to convert
---@return vector3 The rotation vector
Math.NormalToRotation = function(input)
    local inputType = type(input)

    if inputType == 'vector3' then
        local pitch = -math.asin(input.y) * (180.0 / math.pi)
        local yaw = math.atan(input.x, input.z) * (180.0 / math.pi)
        return vector3(pitch, yaw, 0.0)
    end

    error(('cannot convert type %s to a rotation vector'):format(inputType), 2)
end

---Tries to convert its argument to a vector3
---@param input string | table The input to convert
---@param min? number The minimum value
---@param max? number The maximum value
---@param round? boolean Whether to round the values
---@return vector3 The vector3
Math.ToVector = function(input, min, max, round)
    local inputType = type(input)

    if inputType == 'string' then
        local a, b, c, d = Math.ToScalars(input, min, max, round)
        if d ~= nil and type(vector4) == 'function' then
            return vector4(a, b, c, d)
        elseif c ~= nil and type(vector3) == 'function' then
            return vector3(a, b, c)
        elseif b ~= nil and type(vector2) == 'function' then
            return vector2(a, b)
        else
            return (a or 0) + 0.0
        end
    end

    if inputType == 'table' then
        for _, v in pairs(input) do
            Math.ParseNumber(v, min, max, round)
        end

        local len = #input
        if len > 0 then
            if len == 4 and type(vector4) == 'function' then
                return vector4(input[1], input[2], input[3], input[4])
            elseif len == 3 and type(vector3) == 'function' then
                return vector3(input[1], input[2], input[3])
            elseif len == 2 and type(vector2) == 'function' then
                return vector2(input[1], input[2])
            else
                return (input[1] or 0) + 0.0
            end
        end

        return (input.w and type(vector4) == 'function') and vector4(input.x, input.y, input.z, input.w)
            or (input.z and type(vector3) == 'function') and vector3(input.x, input.y, input.z)
            or (input.y and type(vector2) == 'function') and vector2(input.x, input.y)
            or (input.x or 0) + 0.0
    end

    error(('cannot convert %s to a vector value'):format(inputType), 2)
end

---Converts a string to a table of numbers
---@param input string The string to convert
---@param min? number The minimum value
---@param max? number The maximum value
---@param round? boolean Whether to round the values
---@return number ... The numbers
Math.ToScalars = function(input, min, max, round)
    local arr = {}
    local i = 0

    for s in tostring(input):gmatch('[^,%s]+') do
        local n = Math.ParseNumber(s, min, max, round and (round == true or i < round))
        i = i + 1
        arr[i] = n
    end

    return table.unpack(arr)
end

---Parses a number from a string
---@param input string The string to parse
---@param min? number The minimum value
---@param max? number The maximum value
---@param round? boolean Whether to round the value
---@return number
Math.ParseNumber = function(input, min, max, round)
    local n = tonumber(input)

    if not n then
        error(("value cannot be converted into a number (received %s)"):format(input), 3)
    end

    n = round and math.floor(n + 0.5) or n

    if min and n < min then
        error(("value does not meet minimum value of '%s' (received %s)"):format(min, n), 3)
    end

    if max and n > max then
        error(("value exceeds maximum value of '%s' (received %s)"):format(max, n), 3)
    end

    return n
end

---Linearly interpolates between two values over a specified duration.
---@generic T : number | table | vector2 | vector3 | vector4
---@param start T -- The starting value of the interpolation.
---@param finish T -- The ending value of the interpolation.
---@param duration number -- The duration over which to interpolate over in milliseconds.
---@return fun(): T, number
Math.Lerp = function(start, finish, duration)
    local startTime = GetGameTimer()
    local typeStart = type(start)
    local typeFinish = type(finish)

    if typeStart ~= 'number' and typeStart ~= 'vector2' and typeStart ~= 'vector3' and typeStart ~= 'vector4' and typeStart ~= 'table' then
        error(("expected argument 1 to have type '%s' (received %s)"):format('number | table | vector2 | vector3 | vector4', typeStart))
    end

    assert(typeFinish == typeStart, ("expected argument 2 to have type '%s' (received %s)"):format(typeStart, typeFinish))

    local interpFn = typeStart == 'table' and interpolateTable or math.interp
    local step

    return function()
        if not step then
            step = 0
            return start, step
        end

        if step == 1 then return end

        Wait(0)
        step = math.min((GetGameTimer() - startTime) / duration, 1)

        if step < 1 then
            return interpFn(start, finish, step), step
        end

        return finish, step
    end
end

---Calculates the inverse of a linear interpolation between two values.
---@param start number | table | vector2 | vector3 | vector4 -- The starting value of the interpolation.
---@param finish number | table | vector2 | vector3 | vector4 -- The ending value of the interpolation.
---@param value number | table | vector2 | vector3 | vector4 -- The value to calculate the inverse of.
---@return number
Math.InverseLerp = function(start, finish, value)
    if type(start) == 'string' then start = tonumber(start) end
    if type(finish) == 'string' then finish = tonumber(finish) end
    if type(value) == 'string' then value = tonumber(value) end
    if type(start) ~= 'number' then error('Value must be a number') end
    if type(finish) ~= 'number' then error('Value must be a number') end
    if type(value) ~= 'number' then error('Value must be a number') end
    if start == finish then return 0 end
    return (value - start) / (finish - start)
end

---Maps a value from one range to another.
---@param value number | table | vector2 | vector3 | vector4 -- The value to map.
---@param inMin number | table | vector2 | vector3 | vector4 -- The minimum value of the input range.
---@param inMax number | table | vector2 | vector3 | vector4 -- The maximum value of the input range.
---@param outMin number | table | vector2 | vector3 | vector4 -- The minimum value of the output range.
---@param outMax number | table | vector2 | vector3 | vector4 -- The maximum value of the output range.
---@return number | table | vector2 | vector3 | vector4
Math.Map = function(value, inMin, inMax, outMin, outMax)
    if type(value) == 'string' then value = tonumber(value) end
    if type(inMin) == 'string' then inMin = tonumber(inMin) end
    if type(inMax) == 'string' then inMax = tonumber(inMax) end
    if type(outMin) == 'string' then outMin = tonumber(outMin) end
    if type(outMax) == 'string' then outMax = tonumber(outMax) end
    if type(value) ~= 'number' then error('Value must be a number') end
    if type(inMin) ~= 'number' then error('Value must be a number') end
    if type(inMax) ~= 'number' then error('Value must be a number') end
    if type(outMin) ~= 'number' then error('Value must be a number') end
    if type(outMax) ~= 'number' then error('Value must be a number') end
    local t = Math.InverseLerp(inMin, inMax, value)
    return Math.Lerp(outMin, outMax, t)
end

---Converts degrees to radians.
---@param deg number -- The angle in degrees.
---@return number
Math.Deg2Rad = function(deg)
    if type(deg) == 'string' then deg = tonumber(deg) end
    if type(deg) ~= 'number' then error('Value must be a number') end
    return deg * math.pi / 180
end

---Converts radians to degrees.
---@param rad number -- The angle in radians.
---@return number
Math.Rad2Deg = function(rad)
    if type(rad) == 'string' then rad = tonumber(rad) end
    if type(rad) ~= 'number' then error('Value must be a number') end
    return rad * 180 / math.pi
end

---Returns the sign of a number.
---@param x number -- The number to get the sign of.
---@return number
Math.Sign = function(x)
    if type(x) == 'string' then x = tonumber(x) end
    if type(x) ~= 'number' then error('Value must be a number') end
    if x > 0 then return 1 end
    if x < 0 then return -1 end
    return 0
end

---Checks if two numbers are almost equal.
---@param a number -- The first number.
---@param b number -- The second number.
---@param eps number | nil -- The epsilon value to use for comparison. Defaults to 1e-6.
---@return boolean
Math.AlmostEqual = function(a, b, eps)
    if type(a) == 'string' then a = tonumber(a) end
    if type(b) == 'string' then b = tonumber(b) end
    if eps ~= nil and type(eps) == 'string' then eps = tonumber(eps) end
    if type(a) ~= 'number' then error('Value must be a number') end
    if type(b) ~= 'number' then error('Value must be a number') end
    if eps ~= nil and type(eps) ~= 'number' then error('Value must be a number') end
    eps = eps or 1e-6
    return math.abs(a - b) <= eps
end

---Calculates the length of a 2D vector.
---@param x number -- The x component of the vector.
---@param y number -- The y component of the vector.
---@return number
Math.Length2 = function(x, y)
    if type(x) == 'string' then x = tonumber(x) end
    if type(y) == 'string' then y = tonumber(y) end
    if type(x) ~= 'number' then error('Value must be a number') end
    if type(y) ~= 'number' then error('Value must be a number') end
    return math.sqrt(x * x + y * y)
end

---Calculates the length of a 3D vector.
---@param x number -- The x component of the vector.
---@param y number -- The y component of the vector.
---@param z number -- The z component of the vector.
---@return number
Math.Length3 = function(x, y, z)
    if type(x) == 'string' then x = tonumber(x) end
    if type(y) == 'string' then y = tonumber(y) end
    if type(z) == 'string' then z = tonumber(z) end
    if type(x) ~= 'number' then error('Value must be a number') end
    if type(y) ~= 'number' then error('Value must be a number') end
    if type(z) ~= 'number' then error('Value must be a number') end
    return math.sqrt(x * x + y * y + z * z)
end

---Calculates the distance between two 2D points.
---@param x1 number -- The x component of the first point.
---@param y1 number -- The y component of the first point.
---@param x2 number -- The x component of the second point.
---@param y2 number -- The y component of the second point.
---@return number
Math.Distance2D = function(x1, y1, x2, y2)
    if type(x1) == 'string' then x1 = tonumber(x1) end
    if type(y1) == 'string' then y1 = tonumber(y1) end
    if type(x2) == 'string' then x2 = tonumber(x2) end
    if type(y2) == 'string' then y2 = tonumber(y2) end
    if type(x1) ~= 'number' then error('Value must be a number') end
    if type(y1) ~= 'number' then error('Value must be a number') end
    if type(x2) ~= 'number' then error('Value must be a number') end
    if type(y2) ~= 'number' then error('Value must be a number') end
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

---Calculates the distance between two 3D points.
---@param x1 number -- The x component of the first point.
---@param y1 number -- The y component of the first point.
---@param z1 number -- The z component of the first point.
---@param x2 number -- The x component of the second point.
---@param y2 number -- The y component of the second point.
---@param z2 number -- The z component of the second point.
---@return number
Math.Distance3D = function(x1, y1, z1, x2, y2, z2)
    if type(x1) == 'string' then x1 = tonumber(x1) end
    if type(y1) == 'string' then y1 = tonumber(y1) end
    if type(z1) == 'string' then z1 = tonumber(z1) end
    if type(x2) == 'string' then x2 = tonumber(x2) end
    if type(y2) == 'string' then y2 = tonumber(y2) end
    if type(z2) == 'string' then z2 = tonumber(z2) end
    if type(x1) ~= 'number' then error('Value must be a number') end
    if type(y1) ~= 'number' then error('Value must be a number') end
    if type(z1) ~= 'number' then error('Value must be a number') end
    if type(x2) ~= 'number' then error('Value must be a number') end
    if type(y2) ~= 'number' then error('Value must be a number') end
    if type(z2) ~= 'number' then error('Value must be a number') end
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

return Math
