---@class TargetOptions
---@field label string Label for the target
---@field name? string Name of the target
---@field icon? string Icon for the target
---@field iconColor? string Color for the icon
---@field distance? number Distance to the target
---@field bones? string | string[] Bones to attach the target to
---@field offset? vector3 Offset for the target
---@field offsetAbsolute? vector3 Absolute offset for the target
---@field offsetSize? vector3 Size of the offset for the target
---@field groups? string | string[] | table<string, number> Groups to attach the target to
---@field items? string | string[] | table<string, number> Items to attach the target to
---@field anyItem? boolean Whether to attach the target to any item
---@field canInteract? function Function to check if the player can interact with the target
---@field menuName? string Name of the menu
---@field openMenu? string Name of the menu to open
---@field onSelect? function Function to call when the target is selected
---@field export? string Name of the export to use
---@field event? string Name of the event to use
---@field serverEvent? string Name of the server event to use
---@field command? string Name of the command to use

---@class SphereZoneParams
---@field coords vector3 Coordinates of the box zone
---@field name? string Name of the box zone
---@field radius? number Radius of the box zone
---@field debug? boolean Debug mode
---@field drawSprite? boolean Draw sprite
---@field options TargetOptions Options for the zone

---@class BoxZoneParams
---@field coords vector3 Coordinates of the box zone
---@field name? string Name of the box zone
---@field size? number Size of the box zone
---@field rotation? number Rotation of the box zone
---@field debug? boolean Debug mode
---@field drawSprite? boolean Draw sprite
---@field options TargetOptions Options for the zone

---@class PolyZoneParams
---@field coords vector3 Coordinates of the box zone
---@field name? string Name of the box zone
---@field thickness? number Thickness of the box zone
---@field debug? boolean Debug mode
---@field drawSprite? boolean Draw sprite
---@field options TargetOptions Options for the zone

local ox_target = exports.ox_target

return {
    ---@param options TargetOptions Options for the object
    AddGlobalObject = function(options)
        ox_target:addGlobalObject(options)
    end,

    ---@param optionNames string | string[] Option names to remove
    RemoveGlobalObject = function(optionNames)
        ox_target:removeGlobalObject(optionNames)
    end,

    ---@param options TargetOptions Options for the ped
    AddGlobalPed = function(options)
        ox_target:addGlobalPed(options)
    end,

    ---@param options TargetOptions Options for the player
    AddGlobalPlayer = function(options)
        ox_target:addGlobalPlayer(options)
    end,

    ---@param optionNames string | string[] Option names to remove
    RemoveGlobalPlayer = function(optionNames)
        ox_target:removeGlobalPlayer(optionNames)
    end,

    ---@param optionNames string | string[] Option names to remove
    RemoveGlobalPed = function(optionNames)
        ox_target:removeGlobalPed(optionNames)
    end,

    ---@param options TargetOptions Options for the vehicle
    AddGlobalVehicle = function(options)
        ox_target:addGlobalVehicle(options)
    end,

    ---@param optionNames string | string[] Option names to remove
    RemoveGlobalVehicle = function(optionNames)
        ox_target:removeGlobalVehicle(optionNames)
    end,

    ---@param models number | string | number[] | string[] Model hashes
    ---@param options TargetOptions Options for the models
    AddModel = function(models, options)
        ox_target:addModel(models, options)
    end,

    ---@param models number | string | number[] | string[] Model hashes
    ---@param optionNames string | string[] Option names to remove
    RemoveModel = function(models, optionNames)
        ox_target:removeModel(models, optionNames)
    end,

    ---@param entities number | number[] Entity handles
    ---@param options TargetOptions Options for the entities
    AddEntity = function(entities, options)
        ox_target:addLocalEntity(entities, options)
    end,

    ---@param entities number | number[] Entity handles
    ---@param optionNames string | string[] Option names to remove
    RemoveEntity = function(entities, optionNames)
        ox_target:removeLocalEntity(entities, optionNames)
    end,

    ---@param params SphereZoneParams Parameters for the sphere zone
    ---@return number | string ID
    AddSphereZone = function(params)
        ox_target:addSphereZone(params)
    end,

    ---@param params BoxZoneParams Parameters for the box zone
    ---@return number | string ID
    AddBoxZone = function(params)
        ox_target:addBoxZone(params)
    end,

    ---@param params PolyZoneParams Parameters for the poly zone
    ---@return number | string ID
    AddPolyZone = function(params)
        ox_target:addPolyZone(params)
    end,

    ---@param id number | string ID of the zone
    RemoveZone = function(id)
        ox_target:removeZone(id)
    end,
}