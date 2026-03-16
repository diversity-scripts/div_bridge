local Database = {}

---@return string
Database.GetResourceName = function()
    return 'custom'
end

-- Fetch multiple rows
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Select = function(query, parameters)
    return 0
end

---Execute query (Returns affected rows count)
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Execute = function(query, parameters)
    return 0
end

-- Fetch single value
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Scalar = function(query, parameters)
    return 0
end

-- Insert row (Returns ID)
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Insert = function(query, parameters)
    return 0
end

-- Update/Delete (Returns affected rows count)
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Update = function(query, parameters)
    return 0
end

-- Transaction (Batch operations)
---@param queries string[] SQL queries
---@param parameters? any[] Parameters for the queries
---@return promise
Database.Transaction = function(queries, parameters)
    return 0
end

return Database