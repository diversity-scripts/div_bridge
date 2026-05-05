local Raycast = {}

local StartShapeTestLosProbe = StartShapeTestLosProbe
local GetShapeTestResultIncludingMaterial = GetShapeTestResultIncludingMaterial
local StartShapeTestRay = StartShapeTestRay
local GetShapeTestResult = GetShapeTestResult
local math_abs = math.abs
local GetFinalRenderedCamCoord = GetFinalRenderedCamCoord
local GetFinalRenderedCamRot = GetFinalRenderedCamRot

---@alias ShapetestIgnore
---| 1 GLASS
---| 2 SEE_THROUGH
---| 3 GLASS | SEE_THROUGH
---| 4 NO_COLLISION
---| 7 GLASS | SEE_THROUGH | NO_COLLISION

---@alias ShapetestFlags integer
---| 1 INCLUDE_MOVER
---| 2 INCLUDE_VEHICLE
---| 4 INCLUDE_PED
---| 8 INCLUDE_RAGDOLL
---| 16 INCLUDE_OBJECT
---| 32 INCLUDE_PICKUP
---| 64 INCLUDE_GLASS
---| 128 INCLUDE_RIVER
---| 256 INCLUDE_FOLIAGE
---| 511 INCLUDE_ALL

local function getForwardVector()
    local camRot = rotation or GetFinalRenderedCamRot(2)

    local rx = math.rad(camRot.x)
    local ry = math.rad(camRot.y)
    local rz = math.rad(camRot.z)

    local sx = math.sin(rx)
    local cx = math.cos(rx)
    local sy = math.sin(ry)
    local cy = math.cos(ry)
    local sz = math.sin(rz)
    local cz = math.cos(rz)

    local x = -sz * math.abs(cx)
    local y = cz * math.abs(cx)
    local z = sx

    return vector3(x, y, z)
end

---@param coords vector3
---@param destination vector3
---@param flags ShapetestFlags? Defaults to 511.
---@param ignore ShapetestIgnore? Defaults to 4.
---@param ignoreEntity number? Defaults to playerPed.
---@return boolean hit
---@return number entityHit
---@return vector3 endCoords
---@return vector3 surfaceNormal
---@return number materialHash
Raycast.FromCoords = function(coords, destination, flags, ignore, ignoreEntity)
    if type(coords) ~= 'vector3' then
        error(('Expected coords to have type "vector3" (received %s)'):format(type(coords)))
    end
    if type(destination) ~= 'vector3' then
        error(('Expected destination to have type "vector3" (received %s)'):format(type(destination)))
    end

    local handle = StartShapeTestLosProbe(coords.x, coords.y, coords.z, destination.x, destination.y, destination.z, flags or 511, ignoreEntity or cache.ped, ignore or 4)
    local retval, hit, endCoords, surfaceNormal, material, entityHit = 1, nil, nil, nil, nil, nil
    
    local timeout = 500
    while retval == 1 and timeout > 0 do
        retval, hit, endCoords, surfaceNormal, material, entityHit = GetShapeTestResultIncludingMaterial(handle)
        timeout = timeout - 1
        Wait(0)
    end
    return hit, entityHit, endCoords, surfaceNormal, material
end

---@param distance number? Defaults to 10.
---@param flags ShapetestFlags? Defaults to 511.
---@param ignore ShapetestIgnore? Defaults to 4.
---@param ignoreEntity number? Defaults to playerPed.
Raycast.FromCamera = function(distance, flags, ignore, ignoreEntity)
    if distance ~= nil and type(distance) ~= 'number' then
        error(('Expected distance to have type "number" (received %s)'):format(type(distance)))
    end

    distance = distance or 10
    local coords = GetFinalRenderedCamCoord()
    local destination = coords + getForwardVector() * distance
    return Raycast.FromCoords(coords, destination, flags, ignore, ignoreEntity)
end

return Raycast
