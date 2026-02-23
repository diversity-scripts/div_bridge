return {
    ---@param options TargetOptions Options for the object
    AddGlobalObject = function(options)

    end,

    ---@param optionNames string | string[] Option names to remove
    RemoveGlobalObject = function(optionNames)

    end,

    ---@param options TargetOptions Options for the ped
    AddGlobalPed = function(options)

    end,

    ---@param options TargetOptions Options for the player
    AddGlobalPlayer = function(options)

    end,

    ---@param optionNames string | string[] Option names to remove
    RemoveGlobalPlayer = function(optionNames)

    end,

    ---@param optionNames string | string[] Option names to remove
    RemoveGlobalPed = function(optionNames)

    end,

    ---@param options TargetOptions Options for the vehicle
    AddGlobalVehicle = function(options)

    end,

    ---@param optionNames string | string[] Option names to remove
    RemoveGlobalVehicle = function(optionNames)

    end,

    ---@param models number | string | number[] | string[] Model hashes
    ---@param options TargetOptions Options for the models
    AddModel = function(models, options)

    end,

    ---@param models number | string | number[] | string[] Model hashes
    ---@param optionNames string | string[] Option names to remove
    RemoveModel = function(models, optionNames)

    end,

    ---@param entities number | number[] Entity handles
    ---@param options TargetOptions Options for the entities
    AddEntity = function(entities, options)

    end,

    ---@param entities number | number[] Entity handles
    ---@param optionNames string | string[] Option names to remove
    RemoveEntity = function(entities, optionNames)

    end,

    ---@param params SphereZoneParams Parameters for the sphere zone
    ---@return number | string ID
    AddSphereZone = function(params)

    end,

    ---@param params BoxZoneParams Parameters for the box zone
    ---@return number | string ID
    AddBoxZone = function(params)

    end,

    ---@param params PolyZoneParams Parameters for the poly zone
    ---@return number | string ID
    AddPolyZone = function(params)

    end,

    ---@param id number | string ID of the zone
    RemoveZone = function(id)

    end,
}