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
---@field forceColor? string Color to force the target to draw
---@field forceSeparate? boolean Force the target to draw separately

local core_focus = exports.core_focus
local Interaction = {}
local targetZones = {}

---@return string
Interaction.GetResourceName = function()
    return 'core_focus'
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
    print('core_focus does not support disabling targeting')
end

---@param options TargetOptions Options for the object
Interaction.AddGlobalObject = function(options)
    options = Interaction.FixOptions(options)
    core_focus:AddGlobalObject(options)
end

---@param labels string | string[] Labels to remove
Interaction.RemoveGlobalObject = function(labels)
    core_focus:RemoveGlobalObject(labels)
end

---@param options TargetOptions Options for the ped
Interaction.AddGlobalPed = function(options)
    options = Interaction.FixOptions(options)
    core_focus:AddGlobalPed(options)
end

---@param labels string | string[] Labels to remove
Interaction.RemoveGlobalPed = function(labels)
    core_focus:RemoveGlobalPed(labels)
end

---@param options TargetOptions Options for the player
Interaction.AddGlobalPlayer = function(options)
    options = Interaction.FixOptions(options)
    core_focus:AddGlobalPlayer(options)
end

---@param labels string | string[] Labels to remove
Interaction.RemoveGlobalPlayer = function(labels)
    core_focus:RemoveGlobalPlayer(labels)
end

---@param options TargetOptions Options for the vehicle
Interaction.AddGlobalVehicle = function(options)
    options = Interaction.FixOptions(options)
    core_focus:AddGlobalVehicle(options)
end

---@param labels string | string[] Labels to remove
Interaction.RemoveGlobalVehicle = function(labels)
    core_focus:RemoveGlobalVehicle(labels)
end

---@param models string | string[] Model names
---@param options TargetOptions Options for the models
Interaction.AddModel = function(models, options)
    options = Interaction.FixOptions(options)
    core_focus:AddTargetModel(models, options)
end

---@param models string | string[] Model names
---@param labels string | string[] Labels to remove
Interaction.RemoveModel = function(models, labels)
    core_focus:RemoveTargetModel(models, labels)
end

---@param entity number | number[] Entity handle
---@param options TargetOptions Options for the entity
Interaction.AddLocalEntity = function(entity, options)
    options = Interaction.FixOptions(options)
    core_focus:AddTargetEntity(entity, options)
end

---@param entities number | number[] Entity handles
---@param labels string | string[] Labels to remove
Interaction.RemoveLocalEntity = function(entities, labels)
    core_focus:RemoveTargetEntity(entities, labels)
end

---@param name string Name of the box zone
---@param coords vector3 Coordinates of the box zone
---@param radius number Radius of the box zone
---@param options TargetOptions Options for the zone
---@param debug? boolean Debug mode (optional)
---@return string Name of the zone
Interaction.AddSphereZone = function(name, coords, radius, options, debug)
    options = Interaction.FixOptions(options)
    if not next(options) then return end
    core_focus:AddCircleZone(name, coords, radius, {
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
---@param size number Size of the box zone
---@param rotation number Rotation of the box zone (unused)
---@param options TargetOptions Options for the zone
---@param debug? boolean Debug mode (optional)
---@return string Name of the zone
Interaction.AddBoxZone = function(name, coords, size, rotation, options, debug)
    options = Interaction.FixOptions(options)
    if not next(options) then return end
    core_focus:AddBoxZone(name, coords, size, size, {
        name = name,
        debugPoly = debug or false,
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
---@param options PolyZoneOptions Debug options for the zone
---@param targetOptions TargetOptions Options for the zone
---@param debug? boolean Debug mode (optional)
---@return string Name of the zone
Interaction.AddPolyZone = function(name, points, options, debug)
    options = Interaction.FixOptions(options)
    if not next(options) then return end

    local norm = {}
    if type(points) == 'table' then
        for i = 1, #points do
            local p = points[i]
            local ptType = type(p)
            if ptType == 'vector2' then
                norm[i] = p
            elseif ptType == 'vector3' then
                norm[i] = vector2(p.x, p.y)
            elseif ptType == 'table' then
                local x, y = p.x or p[1], p.y or p[2]
                if x and y then
                    norm[i] = vector2(x, y)
                end
            end
        end
    end

    local minZ = options.minZ
    local maxZ = options.maxZ
    if not (minZ and maxZ) then
        local baseZ = options.z or (options.coords and options.coords.z)
        if not baseZ and type(points) == 'table' then
            local p1 = points[1]
            if p1 then
                local pt = type(p1)
                if pt == 'vector3' then
                    baseZ = p1.z
                elseif pt == 'table' then
                    baseZ = p1.z or p1[3]
                end
            end
        end
        if baseZ then
            local half = (thickness and (thickness * 0.5)) or 1.0
            minZ = minZ or (baseZ - half)
            maxZ = maxZ or (baseZ + half)
        end
    end

    core_focus:AddPolyZone(name, points, {
        name = name,
        debugPoly = debug or false,
        minZ = minZ,
        maxZ = maxZ,
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
            -- qb_target:RemoveZone(name)
            table.remove(targetZones, _)
            break
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, target in pairs(targetZones) do
        if target.creator == resource then
            -- qb_target:RemoveZone(target.name)
        end
    end
    targetZones = {}
end)

return Interaction
