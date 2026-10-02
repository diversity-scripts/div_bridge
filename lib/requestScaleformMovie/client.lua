--[[
    Adapted from ox_lib (https://github.com/overextended/ox_lib)
    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>
    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@param scaleformName string
---@param timeout? number
---@return number? scaleform
local function requestScaleformMovie(scaleformName, timeout)
    if type(scaleformName) ~= 'string' then
        error(('Expected scaleformName to have type "string" (received %s)'):format(type(scaleformName)))
    end

    local scaleform = RequestScaleformMovie(scaleformName)
    timeout = timeout or 5000
    local start = GetGameTimer()
    while not HasScaleformMovieLoaded(scaleformName) do
        if GetGameTimer() - start > timeout then
            error(('Failed to load scaleformName "%s"'):format(scaleformName))
        end
        Wait(0)
    end

    return scaleform
end

return requestScaleformMovie
