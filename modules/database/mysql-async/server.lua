local MySQL = exports['mysql-async']
local Database = {}

---@return string
Database.GetResourceName = function()
    return 'mysql-async'
end

---Fetch multiple rows
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Select = function(query, parameters)
    local p = promise.new()
    MySQL:mysql_fetch_all(query, parameters or {}, function(result)
        p:resolve(result)
    end)
    return p
end

---Execute query (Returns affected rows count)
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Execute = function(query, parameters)
    local p = promise.new()
    MySQL:mysql_execute(query, parameters or {}, function(result)
        p:resolve(result)
    end)
    return p
end

---Fetch single value
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Scalar = function(query, parameters)
    local p = promise.new()
    MySQL:mysql_fetch_scalar(query, parameters or {}, function(result)
        p:resolve(result)
    end)
    return p
end

---Insert row (Returns ID)
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Insert = function(query, parameters)
    local p = promise.new()
    MySQL:mysql_insert(query, parameters or {}, function(result)
        p:resolve(result)
    end)
    return p
end

---Update/Delete (Returns affected rows count)
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Update = function(query, parameters)
    local p = promise.new()
    MySQL:mysql_execute(query, parameters or {}, function(result)
        p:resolve(result)
    end)
    return p
end

---Transaction (Batch operations)
---@param queries string[] SQL queries
---@param parameters? any[] Parameters for the queries
---@return promise
Database.Transaction = function(queries, parameters)
    local p = promise.new()
    MySQL:mysql_transaction(queries, parameters or {}, function(result)
        p:resolve(result)
    end)
    return p
end

return Database