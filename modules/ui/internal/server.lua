-------------------------------------------------------------------------------
-- Internal UI Implementation (Server)
-- Server-side notification routing (to player, to all, to job, to ACE).
-------------------------------------------------------------------------------

local UI = {}
local dBridge = _ENV.dBridge

---@param target number Player server ID
---@param data table Notification data
UI.ToPlayer = function(target, data)
    TriggerClientEvent('div_bridge:client:ui:notify', target, data)
end

---@param data table Notification data
UI.ToAllPlayers = function(data)
    TriggerClientEvent('div_bridge:client:ui:notify', -1, data)
end

---@param job string Job name
---@param data table Notification data
UI.ToJob = function(job, data)
    if not dBridge or not dBridge.Framework then
        print('^1[div_bridge - UI] Error: ToJob requires a loaded Framework module.^0')
        return
    end

    local fw = dBridge.Framework

    if not fw.GetPlayerJob then
        print('^1[div_bridge - UI] Error: Framework module does not support GetPlayerJob.^0')
        return
    end

    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        local currentJob = fw.GetPlayerJob(src)
        if currentJob and currentJob.name == job then
            TriggerClientEvent('div_bridge:client:ui:notify', src, data)
        end
    end
end

---@param permission string ACE permission
---@param data table Notification data
UI.ToACEPermission = function(permission, data)
    for _, playerId in ipairs(GetPlayers()) do
        if IsPlayerAceAllowed(playerId, permission) then
            TriggerClientEvent('div_bridge:client:ui:notify', tonumber(playerId), data)
        end
    end
end

RegisterNetEvent('div_bridge:server:ui:notify', function(data)
    TriggerClientEvent('div_bridge:client:ui:notify', source, data)
end)

return UI
