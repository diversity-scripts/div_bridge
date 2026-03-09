local Database = {}

---@return string
Database.GetResourceName = function()
    return 'custom'
end

-- Fetch multiple rows
Database.Select = function(query, parameters)
    return {}
end

-- Fetch single value
Database.Scalar = function(query, parameters)
    return 0
end

-- Insert row (Returns ID)
Database.Insert = function(query, parameters)
    return 0
end

-- Update/Delete (Returns affected rows count)
Database.Update = function(query, parameters)
    return 0
end

-- Transaction (Batch operations)
Database.Transaction = function(queries, parameters)
    return 0
end

return Database