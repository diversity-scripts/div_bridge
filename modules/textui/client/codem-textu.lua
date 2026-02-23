local codem_textui = exports['codem-textui']

return {
    ---@param text string
    Show = function(text)
        codem_textui:OpenTextUI(text, 'thema-1')
    end,

    Hide = function()
        codem_textui:CloseTextUI()
    end,
}