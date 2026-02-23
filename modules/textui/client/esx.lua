local esx_textui = exports.esx_textui

return {
    ---@param text string
    Show = function(text)
        esx_textui.TextUI(text)
    end,

    Hide = function()
        esx_textui.HideUI()
    end,
}