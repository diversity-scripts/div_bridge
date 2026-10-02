--[[
    Adapted from ox_lib (https://github.com/overextended/ox_lib)
    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>
    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@param model string | number
---@param timeout? number
---@return number model
local function requestModel(model, timeout)
    if type(model) ~= 'number' then model = joaat(model) end
    if HasModelLoaded(model) then return model end

    if not IsModelValid(model) or not IsModelInCdimage(model) then
        return error(('Attempted to load invalid model "%s"'):format(model))
    end

    return dLib.streamingRequest(RequestModel, HasModelLoaded, 'model', model, timeout)
end

return requestModel
