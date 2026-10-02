--[[
    Adapted from ox_lib (https://github.com/overextended/ox_lib)
    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>
    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@param animSet string
---@param timeout? number
---@return string animSet
local function requestAnimSet(animSet, timeout)
    if HasAnimSetLoaded(animSet) then return animSet end

    if type(animSet) ~= 'string' then
        error(('Expected animSet to have type "string" (received %s)'):format(type(animSet)))
    end

    return dLib.streamingRequest(RequestAnimSet, HasAnimSetLoaded, 'animSet', animSet, timeout)
end

return requestAnimSet
