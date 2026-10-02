--[[
    Adapted from ox_lib (https://github.com/overextended/ox_lib)
    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>
    Copyright © 2025 Linden <https://github.com/thelindat>

    Adapted for div_bridge: inline polling loop instead of ox_lib's lib.waitFor,
    and a 5000ms default timeout.
]]

-------------------------------------------------------------------------------
-- Internal streaming helper (client)
-- Shared polling loop used by the requestModel/requestAnimDict/... modules.
-- Not intended for direct use; access the specific request modules instead
-- (e.g. dLib.requestModel).
-------------------------------------------------------------------------------

---@param requestFn fun(asset: string | number)
---@param hasLoaded fun(asset: string | number): boolean
---@param assetType string
---@param asset string | number
---@param timeout? number
---@return string | number asset
local function streamingRequest(requestFn, hasLoaded, assetType, asset, timeout)
    if hasLoaded(asset) then return asset end

    requestFn(asset)
    timeout = timeout or 5000
    local start = GetGameTimer()
    while not hasLoaded(asset) do
        if GetGameTimer() - start > timeout then
            error(('Failed to load %s "%s" - this may be caused by\n- too many loaded assets\n- oversized, invalid, or corrupted assets'):format(assetType, asset))
        end
        Wait(0)
    end

    return asset
end

return streamingRequest
