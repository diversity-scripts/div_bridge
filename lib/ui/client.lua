local UI = {}

---@param text string
---@param x number
---@param y number
---@param scale? number
---@param color? table
---@param font? number
UI.Draw2DText = function(text, x, y, scale, color, font)
    if not text or not x or not y or not scale then
        return error('DrawText requires text, x, y, and scale options.')
    end
    if color ~= nil and type(color) ~= 'table' then
        return error(('Expected color to have type "table" (received %s)'):format(type(color)))
    end

    local r = color and color.r or 255
    local g = color and color.g or 255
    local b = color and color.b or 255
    local a = color and color.a or 215

    SetTextScale(scale or 0.35, scale or 0.35)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextFont(font or 4)
    SetTextProportional(true)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y)
end

---@param text string
---@param coords vector3
---@param scale? number
---@param color? table
---@param font? number
UI.Draw3DText = function(text, coords, scale, color, font)
    if not coords or not text then
        return error('Draw3DText requires coords and text options.')
    end
    if color ~= nil and type(color) ~= 'table' then
        return error(('Expected color to have type "table" (received %s)'):format(type(color)))
    end

    local r = color and color.r or 255
    local g = color and color.g or 255
    local b = color and color.b or 255
    local a = color and color.a or 215

    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    SetTextScale(scale or 0.35, scale or 0.35)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextFont(font or 4)
    SetTextProportional(true)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param color? table
UI.DrawRect = function(x, y, width, height, color)
    if not x or not y or not width or not height then
        return error('DrawRect requires x, y, width, and height options.')
    end
    if color ~= nil and type(color) ~= 'table' then
        return error(('Expected color to have type "table" (received %s)'):format(type(color)))
    end

    local r = color and color.r or 255
    local g = color and color.g or 255
    local b = color and color.b or 255
    local a = color and color.a or 215

    SetDrawOrigin(x, y, 0.0, 0)
    DrawRect(width, height, r, g, b, a)
    ClearDrawOrigin()
end

return UI