---@diagnostic disable: duplicate-doc-field

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

local ox_target = exports.ox_target
local Interaction = {}
local targetZones = {}

---@return string
Interaction.GetResourceName = function()
    return 'ox_target'
end

---This is an internal function that is used to fix the options passed to fit alternative target systems, for example qb-ox or ox-qb etc.
---@param options table
---@return table
Interaction.FixOptions = function(options)
    for _, v in pairs(options) do
        local action = v.onSelect or v.action
        if not action then
            local _type = v.type
            if _type and _type == 'server' then
                v.serverEvent = v.event
                v.event = nil
            end
        else
            local select = function(entityOrData, ...)
                if type(entityOrData) == 'table' then
                    return action(entityOrData.entity or entityOrData, ...)
                end
                return action(entityOrData, ...)
            end
            v.onSelect = select
        end
        v.groups = v.job or v.groups
        v.canInteract = v.canInteract and function(...)
            return v.canInteract(...)
        end
    end
    return options
end

---@param bool boolean
Interaction.DisableTargeting = function(bool)
    ox_target:disableTargeting(bool)
end

---@param options TargetOptions Options for the object
Interaction.AddGlobalObject = function(options)
    options = Interaction.FixOptions(options)
    ox_target:addGlobalObject(options)
end

---@param optionNames string | string[] Option names to remove
Interaction.RemoveGlobalObject = function(optionNames)
    ox_target:removeGlobalObject(optionNames)
end

---@param options TargetOptions Options for the ped
Interaction.AddGlobalPed = function(options)
    options = Interaction.FixOptions(options)
    ox_target:addGlobalPed(options)
end

---@param optionNames string | string[] Option names to remove
Interaction.RemoveGlobalPed = function(optionNames)
    ox_target:removeGlobalPed(optionNames)
end

---@param options TargetOptions Options for the player
Interaction.AddGlobalPlayer = function(options)
    options = Interaction.FixOptions(options)
    ox_target:addGlobalPlayer(options)
end

---@param optionNames string | string[] Option names to remove
Interaction.RemoveGlobalPlayer = function(optionNames)
    ox_target:removeGlobalPlayer(optionNames)
end

---@param options TargetOptions Options for the vehicle
Interaction.AddGlobalVehicle = function(options)
    options = Interaction.FixOptions(options)
    ox_target:addGlobalVehicle(options)
end

---@param optionNames string | string[] Option names to remove
Interaction.RemoveGlobalVehicle = function(optionNames)
    ox_target:removeGlobalVehicle(optionNames)
end

---@param models number | string | number[] | string[] Model hashes
---@param options TargetOptions Options for the models
Interaction.AddModel = function(models, options)
    options = Interaction.FixOptions(options)
    ox_target:addModel(models, options)
end

---@param models number | string | number[] | string[] Model hashes
---@param optionNames string | string[] Option names to remove
Interaction.RemoveModel = function(models, optionNames)
    ox_target:removeModel(models, optionNames)
end

---@param entities number | number[] Entity handles
---@param options TargetOptions Options for the entities
Interaction.AddLocalEntity = function(entities, options)
    options = Interaction.FixOptions(options)
    ox_target:addLocalEntity(entities, options)
end

---@param entities number | number[] Entity handles
---@param optionNames string | string[] Option names to remove
Interaction.RemoveLocalEntity = function(entities, optionNames)
    ox_target:removeLocalEntity(entities, optionNames)
end

---@field coords vector3 Coordinates of the box zone
---@field name? string Name of the box zone
---@field radius? number Radius of the box zone
---@field options TargetOptions Options for the zone
---@field debug? boolean Debug mode
---@field drawSprite? boolean Draw sprite
---@return number | string ID
Interaction.AddSphereZone = function(coords, name, radius, options, debug, drawSprite)
    local target = ox_target:addSphereZone({
        coords = coords,
        name = name,
        radius = radius,
        options = options,
        debug = debug or false,
        drawSprite = drawSprite or true,
    })
    table.insert(targetZones, {
        id = id,
        name = name,
        creator = GetCurrentResourceName(),
    })
    return target
end

---@field coords vector3 Coordinates of the box zone
---@field name? string Name of the box zone
---@field size? number Size of the box zone
---@field rotation? number Rotation of the box zone
---@field options TargetOptions Options for the zone
---@field debug? boolean Debug mode
---@field drawSprite? boolean Draw sprite
---@return number | string ID
Interaction.AddBoxZone = function(coords, name, size, rotation, options, debug, drawSprite)
    local target = ox_target:addBoxZone({
        coords = coords,
        name = name,
        size = size,
        rotation = rotation,
        options = options,
        debug = debug or false,
        drawSprite = drawSprite or true,
    })
    table.insert(targetZones, {
        id = id,
        name = name,
        creator = GetCurrentResourceName(),
    })
    return target
end

---@field points vector3[] Coordinates of the box zone
---@field name? string Name of the box zone
---@field thickness? number Thickness of the box zone
---@field options TargetOptions Options for the zone
---@field debug? boolean Debug mode
---@field drawSprite? boolean Draw sprite
---@return number | string ID
Interaction.AddPolyZone = function(points, name, thickness, options, debug, drawSprite)
    local target = ox_target:addPolyZone({
        points = points,
        name = name,
        thickness = thickness,
        options = options,
        debug = debug or false,
        drawSprite = drawSprite or true,
    })
    table.insert(targetZones, {
        id = id,
        name = name,
        creator = GetCurrentResourceName(),
    })
    return target
end

---@param id number | string ID of the zone
Interaction.RemoveZone = function(id)
    if not name then return end
    for _, data in pairs(targetZones) do
        if data.id == id or data.name == id then
            ox_target:removeZone(data.id)
            table.remove(targetZones, _)
            break
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, target in pairs(targetZones) do
        if target.creator == resource then
            ox_target:removeZone(target.id)
        end
    end
    targetZones = {}
end)

return Interaction
