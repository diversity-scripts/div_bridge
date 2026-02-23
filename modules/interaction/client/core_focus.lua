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

---@class SphereZoneOptions
---@field name string Name of the box zone
---@field debugPoly? boolean Debug mode
---@field useZ? boolean Use Z coordinate for the box zone

---@class BoxZoneOptions
---@field name string Name of the box zone
---@field heading number Heading of the box zone
---@field debugPoly? boolean Debug mode
---@field minZ number Minimum Z coordinate for the poly zone
---@field maxZ number Maximum Z coordinate for the poly zone

---@class PolyZoneOptions
---@field name string Name of the box zone
---@field debugPoly? boolean Debug mode
---@field minZ number Minimum Z coordinate for the poly zone
---@field maxZ number Maximum Z coordinate for the poly zone

local core_focus = exports.core_focus

return {
    ---@param params TargetOptions Options for the object
    AddGlobalObject = function(params)
        core_focus:AddGlobalObject(params)
    end,

    ---@param labels string | string[] Labels to remove
    RemoveGlobalObject = function(labels)
        core_focus:RemoveGlobalObject(labels)
    end,

    ---@param params TargetOptions Options for the ped
    AddGlobalPed = function(params)
        core_focus:AddGlobalPed(params)
    end,

    ---@param labels string | string[] Labels to remove
    RemoveGlobalPed = function(labels)
        core_focus:RemoveGlobalPed(labels)
    end,

    ---@param params TargetOptions Options for the player
    AddGlobalPlayer = function(params)
        core_focus:AddGlobalPlayer(params)
    end,

    ---@param labels string | string[] Labels to remove
    RemoveGlobalPlayer = function(labels)
        core_focus:RemoveGlobalPlayer(labels)
    end,

    ---@param params TargetOptions Options for the vehicle
    AddGlobalVehicle = function(params)
        core_focus:AddGlobalVehicle(params)
    end,

    ---@param labels string | string[] Labels to remove
    RemoveGlobalVehicle = function(labels)
        core_focus:RemoveGlobalVehicle(labels)
    end,

    ---@param models string | string[] Model names
    ---@param params TargetOptions Options for the models
    AddModel = function(models, params)
        core_focus:AddTargetModel(models, params)
    end,

    ---@param models string | string[] Model names
    ---@param labels string | string[] Labels to remove
    RemoveModel = function(models, labels)
        core_focus:RemoveTargetModel(models, labels)
    end,

    ---@param entity number | number[] Entity handle
    ---@param params TargetOptions Options for the entity
    AddEntity = function(entity, params)
        core_focus:AddTargetEntity(entity, params)
    end,

    ---@param entities number | number[] Entity handles
    ---@param labels string | string[] Labels to remove
    RemoveEntity = function(entities, labels)
        core_focus:RemoveTargetEntity(entities, labels)
    end,

    ---@param name string Name of the box zone
    ---@param center vector3 Coordinates of the box zone
    ---@param radius number Radius of the box zone
    ---@param options SphereZoneOptions Debug options for the zone
    ---@param targetOptions TargetOptions Options for the zone
    AddSphereZone = function(name, center, radius, options, targetOptions)
        core_focus:AddCircleZone(name, center, radius, options, targetOptions)
    end,

    ---@param name string Name of the box zone
    ---@param center vector3 Coordinates of the box zone
    ---@param length number Length of the box zone
    ---@param width number Width of the box zone
    ---@param options BoxZoneOptions Debug options for the zone
    ---@param targetOptions TargetOptions Options for the zone
    AddBoxZone = function(name, center, length, width, options, targetOptions)
        core_focus:AddBoxZone(name, center, length, width, options, targetOptions)
    end,

    ---@param name string Name of the poly zone
    ---@param points vector2[] Coordinates of the poly zone
    ---@param options PolyZoneOptions Debug options for the zone
    ---@param targetOptions TargetOptions Options for the zone
    AddPolyZone = function(name, points, options, targetOptions)
        core_focus:AddPolyZone(name, points, options, targetOptions)
    end,

    ---@param name string Name of the zone
    RemoveZone = function(name)
        -- exports['qb-target']:RemoveZone(name)
    end,
}