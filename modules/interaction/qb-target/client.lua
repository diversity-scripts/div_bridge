---@diagnostic disable: duplicate-doc-field

---@class Options
---@field num? number Position of the option
---@field type string Type of the option
---@field event string Name of the event to use
---@field icon string Icon for the target
---@field label string Label for the target
---@field targeticon? string Icon for the target
---@field item? string Item to use
---@field action? function Action to perform
---@field canInteract? function Function to check if the player can interact
---@field job? string | table Job required to interact
---@field gang? string | table Gang required to interact
---@field citizenid? string | table Citizen ID required to interact
---@field drawDistance? number Distance to draw the target
---@field drawColor? table Color to draw the target
---@field successDrawColor? table Color to draw the target on success

---@class TargetOptions
---@field options Options Options for the target
---@field distance number Distance to the target

local qb_target = exports['qb-target']
local Interaction = {}
local targetZones = {}

---@return string
Interaction.GetResourceName = function()
    return 'qb-target'
end

---This is an internal function that is used to fix the options passed to fit alternative target systems, for example qb-ox or ox-qb etc.
---@param options table
---@return table
Interaction.FixOptions = function(options)
    for k, v in pairs(options) do
        local action = v.onSelect or v.action
        local select = action and function(entityOrData)
            if type(entityOrData) == 'table' then
                return action(entityOrData.entity)
            end
            return action(entityOrData)
        end

        local canInteract = v.canInteract
        local canInteractStatus = canInteract and function(...)
            return canInteract(...)
        end

        if v.serverEvent then
            v.type = 'server'
            v.event = v.serverEvent
        elseif v.event then
            v.type = 'client'
            v.event = v.event
        end

        options[k].action = select
        options[k].job = v.job or v.groups
        options[k].jobType = v.jobType
        options[k].canInteract = canInteractStatus
    end
    return options
end

---@param bool boolean
Interaction.DisableTargeting = function(bool)
    qb_target:AllowTargeting(not bool)
end

---@param params TargetOptions Options for the object
Interaction.AddGlobalObject = function(params)
    params.options = Interaction.FixOptions(params.options)
    qb_target:AddGlobalObject(params)
end

---@param labels string | string[] Labels to remove
Interaction.RemoveGlobalObject = function(labels)
    qb_target:RemoveGlobalObject(labels)
end

---@param params TargetOptions Options for the ped
Interaction.AddGlobalPed = function(params)
    params.options = Interaction.FixOptions(params.options)
    qb_target:AddGlobalPed(params)
end

---@param labels string | string[] Labels to remove
Interaction.RemoveGlobalPed = function(labels)
    qb_target:RemoveGlobalPed(labels)
end

---@param params TargetOptions Options for the player
Interaction.AddGlobalPlayer = function(params)
    params.options = Interaction.FixOptions(params.options)
    qb_target:AddGlobalPlayer(params)
end

---@param labels string | string[] Labels to remove
Interaction.RemoveGlobalPlayer = function(labels)
    qb_target:RemoveGlobalPlayer(labels)
end

---@param params TargetOptions Options for the vehicle
Interaction.AddGlobalVehicle = function(params)
    params.options = Interaction.FixOptions(params.options)
    qb_target:AddGlobalVehicle(params)
end

---@param labels string | string[] Labels to remove
Interaction.RemoveGlobalVehicle = function(labels)
    qb_target:RemoveGlobalVehicle(labels)
end

---@param models string | string[] Model names
---@param params TargetOptions Options for the models
Interaction.AddModel = function(models, params)
    params.options = Interaction.FixOptions(params.options)
    qb_target:AddTargetModel(models, params)
end

---@param models string | string[] Model names
---@param labels string | string[] Labels to remove
Interaction.RemoveModel = function(models, labels)
    qb_target:RemoveTargetModel(models, labels)
end

---@param entity number | number[] Entity handle
---@param params TargetOptions Options for the entity
Interaction.AddEntity = function(entity, params)
    params.options = Interaction.FixOptions(params.options)
    qb_target:AddTargetEntity(entity, params)
end

---@param entities number | number[] Entity handles
---@param labels string | string[] Labels to remove
Interaction.RemoveEntity = function(entities, labels)
    qb_target:RemoveTargetEntity(entities, labels)
end

---@param name string Name of the box zone
---@param coords vector3 Coordinates of the box zone
---@param radius number Radius of the box zone
---@param options TargetOptions Options for the zone
---@param debug? boolean Debug options for the zone (optional)
---@return string Name of the zone
Interaction.AddSphereZone = function(name, coords, radius, options, debug)
    options = Interaction.FixOptions(options)
    if not next(options) then return end
    qb_target:AddCircleZone(name, coords, radius, {
        name = name,
        debugPoly = debug or false,
    }, {
        options = options,
        distance = options.distance or 1.5,
    })
    table.insert(targetZones, {
        name = name,
        creator = GetCurrentResourceName(),
    })
    return name
end

---@param name string Name of the box zone
---@param coords vector3 Coordinates of the box zone
---@param size vector3 Size of the box zone
---@param options TargetOptions Options for the zone
---@param debug? boolean Debug options for the zone (optional)
---@return string Name of the zone
Interaction.AddBoxZone = function(name, coords, size, options, debug)
    options = Interaction.FixOptions(options)
    if not next(options) then return end
    qb_target:AddBoxZone(name, coords, size.x, size.y, {
        name = name,
        debugPoly = options.debug or false,
        minZ = coords.z - (size.z * 0.5),
        maxZ = coords.z + (size.z * 0.5),
    }, {
        options = options,
        distance = options.distance or 1.5,
    })
    table.insert(targetZones, {
        name = name,
        creator = GetCurrentResourceName(),
    })
    return name
end

---@param name string Name of the poly zone
---@param points vector2[] Coordinates of the poly zone
---@param options TargetOptions Options for the zone
---@param debug? boolean Debug options for the zone (optional)
---@return string Name of the zone
Interaction.AddPolyZone = function(name, points, options, debug)
    options = Interaction.FixOptions(options)
    if not next(options) then return end
    qb_target:AddPolyZone(name, points, {
        name = name,
        debugPoly = debug or false,
        -- minZ = points[1].z - 1.0,
        -- maxZ = points[1].z + 1.0,
    }, {
        options = options,
        distance = options.distance or 1.5,
    })
    table.insert(targetZones, {
        name = name,
        creator = GetCurrentResourceName(),
    })
    return name
end

---@param name string Name of the zone
Interaction.RemoveZone = function(name)
    if not name then return end
    for _, data in pairs(targetZones) do
        if data.name == name then
            qb_target:RemoveZone(name)
            table.remove(targetZones, _)
            break
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, target in pairs(targetZones) do
        if target.creator == resource then
            qb_target:RemoveZone(target.name)
        end
    end
    targetZones = {}
end)

return Interaction
