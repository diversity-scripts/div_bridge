local brutal_textui = exports['brutal_textui']

return {
    ---@param text string
    Show = function(text)
        brutal_textui:Open(text, 'gray', 1, 'right')
    end,

    Hide = function()
        brutal_textui:Close()
    end,
}