local Interaction = {}

---@return string
Interaction.GetResourceName = function()
    return 'custom'
end

---@param options TargetOptions Options for the object
Interaction.AddGlobalObject = function(options)

end

---@param optionNames string | string[] Option names to remove
Interaction.RemoveGlobalObject = function(optionNames)

end

---@param options TargetOptions Options for the ped
Interaction.AddGlobalPed = function(options)

end

---@param options TargetOptions Options for the player
Interaction.AddGlobalPlayer = function(options)

end

---@param optionNames string | string[] Option names to remove
Interaction.RemoveGlobalPlayer = function(optionNames)

end

---@param optionNames string | string[] Option names to remove
Interaction.RemoveGlobalPed = function(optionNames)

end

---@param options TargetOptions Options for the vehicle
Interaction.AddGlobalVehicle = function(options)

end

---@param optionNames string | string[] Option names to remove
Interaction.RemoveGlobalVehicle = function(optionNames)

end

---@param models number | string | number[] | string[] Model hashes
---@param options TargetOptions Options for the models
Interaction.AddModel = function(models, options)

end

---@param models number | string | number[] | string[] Model hashes
---@param optionNames string | string[] Option names to remove
Interaction.RemoveModel = function(models, optionNames)

end

---@param entities number | number[] Entity handles
---@param options TargetOptions Options for the entities
Interaction.AddEntity = function(entities, options)

end

---@param entities number | number[] Entity handles
---@param optionNames string | string[] Option names to remove
Interaction.RemoveEntity = function(entities, optionNames)

end

---@param params SphereZoneParams Parameters for the sphere zone
Interaction.AddSphereZone = function(params)

end

---@param params BoxZoneParams Parameters for the box zone
Interaction.AddBoxZone = function(params)

end

---@param params PolyZoneParams Parameters for the poly zone
Interaction.AddPolyZone = function(params)

end

---@param id number | string ID of the zone
Interaction.RemoveZone = function(id)

end

return Interaction
