--[[
    Adapted from ox_lib (https://github.com/overextended/ox_lib)
    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>
    Copyright © 2025 Linden <https://github.com/thelindat>

    Adapted for div_bridge: the reactive runtime values (ped/vehicle/seat/etc.)
    are maintained by this module directly since the bridge has no native cache
    backend, and change listeners use cache.onChange instead of ox_lib events.
]]

-------------------------------------------------------------------------------
-- cache
-- A lightweight port of ox_lib's cache. Two behaviours in one table:
--
--   1. Memoize:  cache('key', function() return expensive() end, timeout?)
--                Stores the result under 'key'; optional timeout (ms) clears it.
--
--   2. Reactive runtime values:  cache.ped, cache.vehicle, cache.seat,
--      cache.playerId, cache.serverId (client), plus cache.game / cache.resource.
--      Unlike ox_lib these are maintained by this module directly (the bridge
--      has no native cache backend), and updates fire cache:<key> listeners
--      registered via cache.onChange(key, cb).
-------------------------------------------------------------------------------

local isServer = IsDuplicityVersion()
local resourceName = GetCurrentResourceName()

local listeners = {}

local cache

---Register a callback fired when a reactive cache value changes.
---Callback receives (newValue, oldValue).
---@param key string
---@param cb fun(value: any, old: any)
local function onChange(key, cb)
    if type(key) ~= 'string' then
        error(('cache key must be a string (received %s)'):format(type(key)))
    end
    if type(cb) ~= 'function' then
        error(('cache callback must be a function (received %s)'):format(type(cb)))
    end
    local list = listeners[key]
    if not list then
        list = {}
        listeners[key] = list
    end
    list[#list + 1] = cb
end

---Sets a reactive cache value and fires listeners if it changed.
---@param key string
---@param value any
local function set(key, value)
    local old = rawget(cache, key)
    if old == value then return end
    rawset(cache, key, value)

    local list = listeners[key]
    if list then
        for i = 1, #list do
            local cb = list[i]
            Citizen.CreateThreadNow(function()
                cb(value, old)
            end)
        end
    end
end

cache = setmetatable({
    game = GetGameName(),
    resource = resourceName,
}, {
    -- cache('key', func, timeout?) -> memoized value
    __call = function(self, key, func, timeout)
        if type(key) ~= 'string' then
            error(('cache key must be a string (received %s)'):format(type(key)))
        end

        local value = rawget(self, key)
        if value == nil then
            if type(func) ~= 'function' then
                error(('cache initializer must be a function (received %s)'):format(type(func)))
            end
            value = func()
            rawset(self, key, value)
            if timeout then
                SetTimeout(timeout, function() rawset(self, key, nil) end)
            end
        end

        return value
    end,
})

cache.onChange = onChange

-------------------------------------------------------------------------------
-- Client-side reactive runtime values
-------------------------------------------------------------------------------
if not isServer then
    cache.playerId = PlayerId()
    cache.serverId = GetPlayerServerId(cache.playerId)
    cache.ped = PlayerPedId()
    cache.vehicle = false
    cache.seat = false

    CreateThread(function()
        while true do
            local ped = PlayerPedId()
            if ped ~= rawget(cache, 'ped') then
                set('ped', ped)
            end

            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle == 0 then vehicle = false end

            if vehicle ~= rawget(cache, 'vehicle') then
                set('vehicle', vehicle)
            end

            if vehicle then
                local seat = false
                for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
                    if GetPedInVehicleSeat(vehicle, i) == ped then
                        seat = i
                        break
                    end
                end
                if seat ~= rawget(cache, 'seat') then
                    set('seat', seat)
                end
            elseif rawget(cache, 'seat') ~= false then
                set('seat', false)
            end

            Wait(100)
        end
    end)
end

return cache
