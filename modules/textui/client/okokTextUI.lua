local okokTextUI = exports['okokTextUI']

return {
    ---@param text string
    Show = function(text)
        okokTextUI:Open(text, 'lightgrey', 'right', false)
    end,

    Hide = function()
        okokTextUI:Close()
    end,
}