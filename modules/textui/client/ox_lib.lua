Bridge.loadLib()

return {
    ---@param text string
    Show = function(text)
        lib.showTextUI(text)
    end,

    Hide = function()
        lib.hideTextUI()
    end,
}