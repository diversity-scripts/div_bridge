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

local qbtarget = exports['qb-target']

return {
    ---@param params TargetOptions Options for the object
    AddGlobalObject = function(params)
        qbtarget:AddGlobalObject(params)
    end,

    ---@param labels string | string[] Labels to remove
    RemoveGlobalObject = function(labels)
        qbtarget:RemoveGlobalObject(labels)
    end,

    ---@param params TargetOptions Options for the ped
    AddGlobalPed = function(params)
        qbtarget:AddGlobalPed(params)
    end,

    ---@param labels string | string[] Labels to remove
    RemoveGlobalPed = function(labels)
        qbtarget:RemoveGlobalPed(labels)
    end,

    ---@param params TargetOptions Options for the player
    AddGlobalPlayer = function(params)
        qbtarget:AddGlobalPlayer(params)
    end,

    ---@param labels string | string[] Labels to remove
    RemoveGlobalPlayer = function(labels)
        qbtarget:RemoveGlobalPlayer(labels)
    end,

    ---@param params TargetOptions Options for the vehicle
    AddGlobalVehicle = function(params)
        qbtarget:AddGlobalVehicle(params)
    end,

    ---@param labels string | string[] Labels to remove
    RemoveGlobalVehicle = function(labels)
        qbtarget:RemoveGlobalVehicle(labels)
    end,

    ---@param models string | string[] Model names
    ---@param params TargetOptions Options for the models
    AddModel = function(models, params)
        qbtarget:AddTargetModel(models, params)
    end,

    ---@param models string | string[] Model names
    ---@param labels string | string[] Labels to remove
    RemoveModel = function(models, labels)
        qbtarget:RemoveTargetModel(models, labels)
    end,

    ---@param entity number | number[] Entity handle
    ---@param params TargetOptions Options for the entity
    AddEntity = function(entity, params)
        qbtarget:AddTargetEntity(entity, params)
    end,

    ---@param entities number | number[] Entity handles
    ---@param labels string | string[] Labels to remove
    RemoveEntity = function(entities, labels)
        qbtarget:RemoveTargetEntity(entities, labels)
    end,

    ---@param name string Name of the box zone
    ---@param center vector3 Coordinates of the box zone
    ---@param radius number Radius of the box zone
    ---@param options SphereZoneOptions Debug options for the zone
    ---@param targetOptions TargetOptions Options for the zone
    AddSphereZone = function(name, center, radius, options, targetOptions)
        qbtarget:AddCircleZone(name, center, radius, options, targetOptions)
    end,

    ---@param name string Name of the box zone
    ---@param center vector3 Coordinates of the box zone
    ---@param length number Length of the box zone
    ---@param width number Width of the box zone
    ---@param options BoxZoneOptions Debug options for the zone
    ---@param targetOptions TargetOptions Options for the zone
    AddBoxZone = function(name, center, length, width, options, targetOptions)
        qbtarget:AddBoxZone(name, center, length, width, options, targetOptions)
    end,

    ---@param name string Name of the poly zone
    ---@param points vector2[] Coordinates of the poly zone
    ---@param options PolyZoneOptions Debug options for the zone
    ---@param targetOptions TargetOptions Options for the zone
    AddPolyZone = function(name, points, options, targetOptions)
        qbtarget:AddPolyZone(name, points, options, targetOptions)
    end,

    ---@param name string Name of the zone
    RemoveZone = function(name)
        qbtarget:RemoveZone(name)
    end,
}