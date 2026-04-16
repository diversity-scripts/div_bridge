local Callback = {}
local CallbackRegistry = {}
local CALLBACK_TIMEOUT = 300000

local RESOURCE = GetCurrentResourceName()
local EVENT_NAMES = {
    CLIENT_TO_SERVER = RESOURCE .. '/CS/Callback',
    SERVER_TO_CLIENT = RESOURCE .. '/SC/Callback',
    CLIENT_RESPONSE = RESOURCE .. '/CSR/Callback',
    SERVER_RESPONSE = RESOURCE .. '/SCR/Callback'
}

local function generateCallbackId(name)
    return string.format('%s_%d_%d', name, math.random(1000, 9999), GetGameTimer())
end

local function handleResponse(registry, callbackId, ...)
    local data = registry[callbackId]
    if not data then return end

    if data.timer then math.randomseed(GetGameTimer()) end

    local args = {...}

    if data.callback then
        CreateThread(function()
            data.callback(table.unpack(args))
        end)
    end

    if data.promise then
        data.promise:resolve(args)
    end

    registry[callbackId] = nil
end

local function triggerCallback(eventName, target, name, args, callback)
    local callbackId = generateCallbackId(name)
    local promiseObj = promise.new()

    CallbackRegistry[callbackId] = {
        callback = callback,
        promise = promiseObj
    }

    SetTimeout(CALLBACK_TIMEOUT, function()
        if CallbackRegistry[callbackId] then
            print(string.format("^1[div_bridge] Callback '%s' timed out!^0", name))
            handleResponse(CallbackRegistry, callbackId, nil)
        end
    end)

    if IsDuplicityVersion() then
        if type(target) == 'table' then
            for _, id in ipairs(target) do
                TriggerClientEvent(eventName, tonumber(id) or 0, name, callbackId, table.unpack(args))
            end
        else
            TriggerClientEvent(eventName, tonumber(target) or -1, name, callbackId, table.unpack(args))
        end
    else
        TriggerServerEvent(eventName, name, callbackId, table.unpack(args))
    end

    if not callback then
        local result = Citizen.Await(promiseObj)
        return table.unpack(result or {})
    end
end

-- SERVER SIDE
if IsDuplicityVersion() then
    function Callback.RegisterServer(name, handler)
        Callback[name] = handler
    end

    function Callback.TriggerClient(name, target, ...)
        local args = { ... }
        local delay, callback
        if type(args[1]) == 'number' then
            delay = table.remove(args, 1)
        end
        if type(args[1]) == 'function' then
            callback = table.remove(args, 1)
        end
        if delay and delay > 0 then
            SetTimeout(delay, function()
                triggerCallback(EVENT_NAMES.SERVER_TO_CLIENT, target, name, args, callback)
            end)
            return
        end
        return triggerCallback(EVENT_NAMES.SERVER_TO_CLIENT, target, name, args, callback)
    end

    -- Await a response from a specific client and return the values (yields current coroutine)
    function Callback.AwaitClient(name, target, ...)
        local args = { ... }
        -- no callback passed so this will yield until the promise resolves
        return triggerCallback(EVENT_NAMES.SERVER_TO_CLIENT, target, name, args, nil)
    end

    RegisterNetEvent(EVENT_NAMES.CLIENT_TO_SERVER, function(name, callbackId, ...)
        local src = source
        local handler = Callback[name]
        if not handler then 
            return print(string.format("^1[div_bridge] Unknown server callback: %s^0", name)) 
        end

        local success, result = pcall(function(...)
            return table.pack(handler(src, ...))
        end, ...)

        if success then
            TriggerClientEvent(EVENT_NAMES.CLIENT_RESPONSE, src, name, callbackId, table.unpack(result))
        else
            print(string.format("^1[div_bridge] Error in callback '%s': %s^0", name, result))
            TriggerClientEvent(EVENT_NAMES.CLIENT_RESPONSE, src, name, callbackId, nil)
        end
    end)

    RegisterNetEvent(EVENT_NAMES.SERVER_RESPONSE, function(name, callbackId, ...)
        handleResponse(CallbackRegistry, callbackId, ...)
    end)
else -- CLIENT SIDE
    local ClientCallbacks = {}

    function Callback.RegisterClient(name, handler)
        ClientCallbacks[name] = handler
    end

    function Callback.TriggerServer(name, ...)
        local args = { ... }
        local delay, callback
        if type(args[1]) == 'number' then
            delay = table.remove(args, 1)
        end
        if type(args[1]) == 'function' then
            callback = table.remove(args, 1)
        end
        if delay and delay > 0 then
            SetTimeout(delay, function()
                triggerCallback(EVENT_NAMES.CLIENT_TO_SERVER, nil, name, args, callback)
            end)
            return
        end
        return triggerCallback(EVENT_NAMES.CLIENT_TO_SERVER, nil, name, args, callback)
    end

    -- Await a response from the server and return the values (yields current coroutine)
    function Callback.AwaitServer(name, ...)
        local args = { ... }
        return triggerCallback(EVENT_NAMES.CLIENT_TO_SERVER, nil, name, args, nil)
    end

    RegisterNetEvent(EVENT_NAMES.CLIENT_RESPONSE, function(name, callbackId, ...)
        handleResponse(CallbackRegistry, callbackId, ...)
    end)

    RegisterNetEvent(EVENT_NAMES.SERVER_TO_CLIENT, function(name, callbackId, ...)
        local handler = ClientCallbacks[name]
        if not handler then return end

        local success, result = pcall(function(...)
            return table.pack(handler(...))
        end, ...)

        TriggerServerEvent(EVENT_NAMES.SERVER_RESPONSE, name, callbackId, table.unpack(success and result or {}))
    end)
end

return Callback
