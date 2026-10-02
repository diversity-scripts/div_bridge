local Config = {}

Config.InteractKey = 47
Config.DefaultDuration = 5000

Config.Priorities = {
    error   = 2,
    warning = 3,
    success = 4,
    info    = 5,
    default = 6,
}

Config.Text = {
    interact = "to Interact",
    exit     = "to Exit",
}

Config.Colors = {
    success = '#57F287',
    error   = '#ED4245',
    warning = '#FEE75C',
    info    = '#3498DB',
    default = '#99AAB5',
    brand   = '#5D36B0'
}

-- Subtitle defaults
Config.Subtitles = {
    position = 'bottom',       -- 'bottom' or 'top'
    typeSpeed = 30,            -- ms per character
    defaultDuration = 5000,    -- ms to show after typing finishes
}

Config.PromptPositions = {
    ['top-left']      = { top = '35vh', left = '1vw', alignItems = 'flex-start' },
    ['top-center']    = { top = '3vh', left = '50%', transform = 'translateX(-50%)', alignItems = 'center' },
    ['top-right']     = { top = '3vh', right = '1vw', alignItems = 'flex-end' },
    ['bottom-left']   = { bottom = '3vh', left = '1vw', alignItems = 'flex-start' },
    ['bottom-center'] = { bottom = '3vh', left = '50%', transform = 'translateX(-50%)', alignItems = 'center' },
    ['bottom-right']  = { bottom = '3vh', right = '1vw', alignItems = 'flex-end' },
}

Config.SkillCheck = {
    defaultKey = 'E',
    difficulties = {
        ['easy']   = { speed = 1.0, areaSize = 60, key = 'E' },
        ['medium'] = { speed = 1.5, areaSize = 40, key = 'E' },
        ['hard']   = { speed = 2.0, areaSize = 25, key = 'E' },
    },
}

Config.Minigames = {
    skillcheck = Config.SkillCheck.difficulties, -- Reuse existing

    rapidkeys = {
        easy   = { keyCount = 4, duration = 6000, showDuration = 2000 },
        medium = { keyCount = 5, duration = 5000, showDuration = 1500 },
        hard   = { keyCount = 7, duration = 4000, showDuration = 1000 },
    },

    memory = {
        easy   = { gridSize = 4, patternLength = 4, previewDuration = 5000, timeLimit = 20000 },
        medium = { gridSize = 4, patternLength = 5, previewDuration = 4000, timeLimit = 15000 },
        hard   = { gridSize = 5, patternLength = 7, previewDuration = 3000, timeLimit = 12000 },
    },

    timingbar = {
        easy   = { rounds = 2, speed = 1.0, zoneSize = 30, zoneShrink = 0, key = "SPACE" },
        medium = { rounds = 3, speed = 1.5, zoneSize = 22, zoneShrink = 3, key = "SPACE" },
        hard   = { rounds = 4, speed = 2.0, zoneSize = 15, zoneShrink = 5, key = "SPACE" },
    },

    wireconnect = {
        easy   = { gridSize = 5, pairs = 3, timeLimit = 20000 },
        medium = { gridSize = 6, pairs = 4, timeLimit = 15000 },
        hard   = { gridSize = 7, pairs = 6, timeLimit = 12000 },
    },

    numberpad = {
        easy   = { code = nil, attempts = 5, timeLimit = 30000, scramble = false, codeLength = 4 },
        medium = { code = nil, attempts = 3, timeLimit = 20000, scramble = false, codeLength = 5 },
        hard   = { code = nil, attempts = 2, timeLimit = 15000, scramble = true, codeLength = 6 },
    },

    lockpick = {
        easy   = { picks = 5, sweetSpotSize = 40, proximityRange = 80, timeLimit = 30000 },
        medium = { picks = 3, sweetSpotSize = 25, proximityRange = 60, timeLimit = 20000 },
        hard   = { picks = 2, sweetSpotSize = 12, proximityRange = 40, timeLimit = 15000 },
    },

    circuitbreaker = {
        easy   = { switchCount = 9, linkedPairs = 3, timeLimit = 30000, maxMoves = nil },
        medium = { switchCount = 16, linkedPairs = 6, timeLimit = 25000, maxMoves = nil },
        hard   = { switchCount = 16, linkedPairs = 10, timeLimit = 15000, maxMoves = 20 },
    },
}

return Config
