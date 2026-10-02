--[[
    Adapted from ox_lib (https://github.com/overextended/ox_lib)
    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>
    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@param textureDict string
---@param timeout? number
---@return string textureDict
local function requestStreamedTextureDict(textureDict, timeout)
    if HasStreamedTextureDictLoaded(textureDict) then return textureDict end

    if type(textureDict) ~= 'string' then
        error(('Expected textureDict to have type "string" (received %s)'):format(type(textureDict)))
    end

    return dLib.streamingRequest(RequestStreamedTextureDict, HasStreamedTextureDictLoaded, 'textureDict', textureDict, timeout)
end

return requestStreamedTextureDict
