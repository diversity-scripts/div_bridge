local KeyMap = {}

KeyMap.KeyToControl = {
    ['ESC'] = 199, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['0'] = 162,
    ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['O'] = 31, ['P'] = 199,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 33, ['D'] = 30, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['ENTER'] = 18, ['LSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244,
    ['LCTRL'] = 36, ['LALT'] = 19, ['SPACE'] = 22,
    ['UP'] = 172, ['DOWN'] = 173, ['LEFT'] = 174, ['RIGHT'] = 175,
    ['DELETE'] = 178
}

KeyMap.ControlToKey = {}
for k, v in pairs(KeyMap.KeyToControl) do
    KeyMap.ControlToKey[v] = k
end

KeyMap.GetKeyFromControl = function(control)
    return KeyMap.ControlToKey[control] or 'KEY'
end

return KeyMap
