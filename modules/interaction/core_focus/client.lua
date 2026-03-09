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

---@return string
Interaction.GetResourceName = function()
    return 'core_focus'
end

---@param bool boolean
Interaction.DisableTargeting = function(bool)

end

---@param params TargetOptions Options for the object
Interaction.AddGlobalObject = function(params)
    core_focus:AddGlobalObject(params)
end

---@param labels string | string[] Labels to remove
Interaction.RemoveGlobalObject = function(labels)
    core_focus:RemoveGlobalObject(labels)
end

---@param params TargetOptions Options for the ped
Interaction.AddGlobalPed = function(params)
    core_focus:AddGlobalPed(params)
end

---@param labels string | string[] Labels to remove
Interaction.RemoveGlobalPed = function(labels)
    core_focus:RemoveGlobalPed(labels)
end

---@param params TargetOptions Options for the player
Interaction.AddGlobalPlayer = function(params)
    core_focus:AddGlobalPlayer(params)
end

---@param labels string | string[] Labels to remove
Interaction.RemoveGlobalPlayer = function(labels)
    core_focus:RemoveGlobalPlayer(labels)
end

---@param params TargetOptions Options for the vehicle
Interaction.AddGlobalVehicle = function(params)
    core_focus:AddGlobalVehicle(params)
end

---@param labels string | string[] Labels to remove
Interaction.RemoveGlobalVehicle = function(labels)
    core_focus:RemoveGlobalVehicle(labels)
end

---@param models string | string[] Model names
---@param params TargetOptions Options for the models
Interaction.AddModel = function(models, params)
    core_focus:AddTargetModel(models, params)
end

---@param models string | string[] Model names
---@param labels string | string[] Labels to remove
Interaction.RemoveModel = function(models, labels)
    core_focus:RemoveTargetModel(models, labels)
end

---@param entity number | number[] Entity handle
---@param params TargetOptions Options for the entity
Interaction.AddEntity = function(entity, params)
    core_focus:AddTargetEntity(entity, params)
end

---@param entities number | number[] Entity handles
---@param labels string | string[] Labels to remove
Interaction.RemoveEntity = function(entities, labels)
    core_focus:RemoveTargetEntity(entities, labels)
end

---@param name string Name of the box zone
---@param coords vector3 Coordinates of the box zone
---@param radius number Radius of the box zone
---@param options TargetOptions Options for the zone
---@param debug? boolean Debug options for the zone (optional)
---@return string Name of the zone
Interaction.AddSphereZone = function(name, coords, radius, options, debug)
    if not next(options) then return end
    core_focus:AddCircleZone(name, coords, radius, {
        name = name,
        debugPoly = debug or false,
    }, {
        options = options,
        distance = options.distance or 1.5,
    })
    return name
end

---@param name string Name of the box zone
---@param coords vector3 Coordinates of the box zone
---@param size number Size of the box zone
---@param options TargetOptions Options for the zone
---@param debug? boolean Debug options for the zone (optional)
---@return string Name of the zone
Interaction.AddBoxZone = function(name, coords, size, options, debug)
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
    return name
end

---@param name string Name of the poly zone
---@param points vector2[] Coordinates of the poly zone
---@param options PolyZoneOptions Debug options for the zone
---@param targetOptions TargetOptions Options for the zone
---@param debug? boolean Debug options for the zone (optional)
---@return string Name of the zone
Interaction.AddPolyZone = function(name, points, options, debug)
    if not next(options) then return end
    core_focus:AddPolyZone(name, points, {
        name = name,
        debugPoly = debug or false,
        -- minZ = points[1].z - 1.0,
        -- maxZ = points[1].z + 1.0,
    }, {
        options = options,
        distance = options.distance or 1.5,
    })
    return name
end

---@param name string Name of the zone
Interaction.RemoveZone = function(name)
    -- exports['qb-target']:RemoveZone(name)
end

return Interaction
