-------------------------------------------------------------------------------
-- Custom UI Adapter (Client)
-- Template for server owners to implement their own UI provider.
-- Fill in the functions below with your custom implementation.
-------------------------------------------------------------------------------

local Adapter = {}

-------------------------------------------------------------------------------
-- Notification
-------------------------------------------------------------------------------

---@param data {type?: string, title?: string, text: string, duration?: number}
Adapter.Notify = function(data)
    -- Your custom notification implementation here
end

-------------------------------------------------------------------------------
-- TextUI
-------------------------------------------------------------------------------

---@param text string Sanitized plain text
Adapter.ShowTextUI = function(text)
    -- Your custom TextUI show implementation here
end

Adapter.HideTextUI = function()
    -- Your custom TextUI hide implementation here
end

-------------------------------------------------------------------------------
-- Progress (optional — remove if you want to fall back to internal)
-------------------------------------------------------------------------------

---@param data table Progress data
---@return boolean completed
-- Adapter.Progress = function(data)
--     return true
-- end

-------------------------------------------------------------------------------
-- Context Menu (optional — remove if you want to fall back to internal)
-------------------------------------------------------------------------------

-- Adapter.RegisterContext = function(data) end
-- Adapter.ShowContext = function(id) end
-- Adapter.HideContext = function() end

-------------------------------------------------------------------------------
-- Input Dialog (optional — remove if you want to fall back to internal)
-------------------------------------------------------------------------------

-- Adapter.InputDialog = function(heading, rows, options) return nil end

-------------------------------------------------------------------------------
-- Skill Check (optional — remove if you want to fall back to internal)
-------------------------------------------------------------------------------

-- Adapter.SkillCheck = function(difficulty, key, callback) callback(false) end

return Adapter
