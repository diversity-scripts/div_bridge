local Streaming = {}

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

---@param model string | number
---@param timeout? number
---@return number model
Streaming.RequestModel = function(model, timeout)
    if type(model) ~= 'number' then model = joaat(model) end
    if HasModelLoaded(model) then return model end
    
    if not IsModelValid(model) or not IsModelInCdimage(model) then
        return error(('Attempted to load invalid model "%s"'):format(model))
    end

    return streamingRequest(RequestModel, HasModelLoaded, 'model', model, timeout)
end

---@param animDict string
---@param timeout? number
---@return string animDict
Streaming.RequestAnimDict = function(animDict, timeout)
    if HasAnimDictLoaded(animDict) then return animDict end

    if type(animDict) ~= 'string' then
        error(('Expected animDict to have type "string" (received %s)'):format(type(animDict)))
    end

    if not DoesAnimDictExist(animDict) then
        error(('Attempted to load invalid animDict "%s"'):format(animDict))
    end

    return streamingRequest(RequestAnimDict, HasAnimDictLoaded, 'animDict', animDict, timeout)
end

---@param animSet string
---@param timeout? number
---@return string animSet
Streaming.RequestAnimSet = function(animSet, timeout)
    if HasAnimSetLoaded(animSet) then return animSet end

    if type(animSet) ~= 'string' then
        error(('Expected animSet to have type "string" (received %s)'):format(type(animSet)))
    end

    return streamingRequest(RequestAnimSet, HasAnimSetLoaded, 'animSet', animSet, timeout)
end

---@param textureDict string
---@param timeout? number
---@return string textureDict
Streaming.RequestStreamedTextureDict = function(textureDict, timeout)
    if HasStreamedTextureDictLoaded(textureDict) then return textureDict end

    if type(textureDict) ~= 'string' then
        error(('Expected textureDict to have type "string" (received %s)'):format(type(textureDict)))
    end

    return streamingRequest(RequestStreamedTextureDict, HasStreamedTextureDictLoaded, 'textureDict', textureDict, timeout)
end

---@param ptFxName string
---@param timeout? number
---@return string ptFxName
Streaming.RequestNamedPtfxAsset = function(ptFxName, timeout)
    if HasNamedPtfxAssetLoaded(ptFxName) then return ptFxName end

    if type(ptFxName) ~= 'string' then
        error(('Expected ptFxName to have type "string" (received %s)'):format(type(ptFxName)))
    end

    return streamingRequest(RequestNamedPtfxAsset, HasNamedPtfxAssetLoaded, 'ptFxName', ptFxName, timeout)
end

---@param audioBank string
---@param timeout? number
---@return string audioBank
Streaming.RequestAudioBank = function(audioBank, timeout)
    if type(audioBank) ~= 'string' then
        error(('Expected audioBank to have type "string" (received %s)'):format(type(audioBank)))
    end

    timeout = timeout or 5000
    local start = GetGameTimer()
    while true do
        if GetGameTimer() - start > timeout then
            error(('Failed to load scaleformName "%s"'):format(scaleformName))
        end

        if RequestScriptAudioBank(audioBank, false) then return end
        Wait(0)
    end

    return audioBank
end

---@param scaleformName string
---@param timeout? number
---@return number? scaleform
Streaming.RequestScaleformMovie = function(scaleformName, timeout)
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

return Streaming
