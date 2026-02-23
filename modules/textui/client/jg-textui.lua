local jg_textui = exports['jg-textui']

return {
    ---@param text string
    Show = function(text)
        jg_textui:DrawText(text)
    end,

    Hide = function()
        jg_textui:HideText()
    end,
}