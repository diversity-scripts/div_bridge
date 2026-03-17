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
---@return table
Database.Select = function(query, parameters)
    return Citizen.Await(promiseWrapper('query', query, parameters))
end

---Execute query (Returns affected rows count)
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return number
Database.Execute = function(query, parameters)
    return Citizen.Await(promiseWrapper('execute', query, parameters))
end

---Fetch single value
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return any
Database.Scalar = function(query, parameters)
    return Citizen.Await(promiseWrapper('scalar', query, parameters))
end

---Insert row (Returns ID)
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return number
Database.Insert = function(query, parameters)
    return Citizen.Await(promiseWrapper('insert', query, parameters))
end

---Update/Delete (Returns affected rows count)
---@param query string SQL query
---@param parameters? any[] Parameters for the query
---@return number
Database.Update = function(query, parameters)
    return Citizen.Await(promiseWrapper('update', query, parameters))
end

---Transaction (Batch operations)
---@param queries string[] SQL queries
---@param parameters? any[] Parameters for the queries
---@return any
Database.Transaction = function(queries, parameters)
    local p = promise.new()
    oxmysql:transaction(queries, parameters or {}, function(result)
        p:resolve(result)
    end)
    return Citizen.Await(p)
end

return Database
