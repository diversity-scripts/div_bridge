--[[
    Adapted from ox_lib (https://github.com/overextended/ox_lib)
    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>
    Copyright © 2025 Linden <https://github.com/thelindat>

    Adapted for div_bridge: inline polling loop instead of ox_lib's lib.waitFor.
]]

---@param audioBank string
---@param timeout? number
---@return string audioBank
local function requestAudioBank(audioBank, timeout)
    if type(audioBank) ~= 'string' then
        error(('Expected audioBank to have type "string" (received %s)'):format(type(audioBank)))
    end

    timeout = timeout or 5000
    local start = GetGameTimer()
    while true do
        if GetGameTimer() - start > timeout then
            error(('Failed to load audioBank "%s"'):format(audioBank))
        end

        if RequestScriptAudioBank(audioBank, false) then return audioBank end
        Wait(0)
    end
end

return requestAudioBank
