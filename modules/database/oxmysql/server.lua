local oxmysql = exports.oxmysql
local Database = {}

local function promiseWrapper(method, query, parameters)
    local p = promise.new()
    oxmysql[method](oxmysql, query, parameters or {}, function(result)
        p:resolve(result)
    end)
    return p
end

---@return string
Database.GetResourceName = function()
    return 'oxmysql'
end

---Fetch multiple rows
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Select = function(query, parameters)
    return promiseWrapper('query', query, parameters)
end

---Execute query (Returns affected rows count)
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Execute = function(query, parameters)
    return promiseWrapper('execute', query, parameters)
end

---Fetch single value
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Scalar = function(query, parameters)
    return promiseWrapper('scalar', query, parameters)
end

---Insert row (Returns ID)
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Insert = function(query, parameters)
    return promiseWrapper('insert', query, parameters)
end

---Update/Delete (Returns affected rows count)
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return promise
Database.Update = function(query, parameters)
    return promiseWrapper('update', query, parameters)
end

---Transaction (Batch operations)
---@param queries string[] SQL queries
---@param parameters? any[] Parameters for the queries
---@return promise
Database.Transaction = function(queries, parameters)
    local p = promise.new()
    oxmysql:transaction(queries, parameters or {}, function(result)
        p:resolve(result)
    end)
    return p
end

return Database