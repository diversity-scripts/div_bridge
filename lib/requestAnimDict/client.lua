--[[
    Adapted from ox_lib (https://github.com/overextended/ox_lib)
    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>
    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@param animDict string
---@param timeout? number
---@return string animDict
local function requestAnimDict(animDict, timeout)
    if HasAnimDictLoaded(animDict) then return animDict end

    if type(animDict) ~= 'string' then
        error(('Expected animDict to have type "string" (received %s)'):format(type(animDict)))
    end

    if not DoesAnimDictExist(animDict) then
        error(('Attempted to load invalid animDict "%s"'):format(animDict))
    end

    return dLib.streamingRequest(RequestAnimDict, HasAnimDictLoaded, 'animDict', animDict, timeout)
end

return requestAnimDict
