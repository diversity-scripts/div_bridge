local qbcore = exports['qb-core']

return {
    ---@param text string
    Show = function(text)
        qbcore:DrawText(text, 'right')
    end,

    Hide = function()
        qbcore:HideText()
    end,
}