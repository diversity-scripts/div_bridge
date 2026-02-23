local oxmysql = exports.oxmysql

local function promiseWrapper(method, query, parameters)
    local p = promise.new()
    oxmysql[method](oxmysql, query, parameters or {}, function(result)
        p:resolve(result)
    end)
    return p
end

return {
    -- Fetch multiple rows
    ---@param query string SQL query
    ---@param parameters? any[] Parameters for the query
    ---@return promise
    Select = function(query, parameters)
        return promiseWrapper('query', query, parameters)
    end,

    -- Fetch single value
    ---@param query string SQL query
    ---@param parameters? any[] Parameters for the query
    ---@return promise
    Scalar = function(query, parameters)
        return promiseWrapper('scalar', query, parameters)
    end,

    -- Insert row (Returns ID)
    ---@param query string SQL query
    ---@param parameters? any[] Parameters for the query
    ---@return promise
    Insert = function(query, parameters)
        return promiseWrapper('insert', query, parameters)
    end,

    -- Update/Delete (Returns affected rows count)
    ---@param query string SQL query
    ---@param parameters? any[] Parameters for the query
    ---@return promise
    Update = function(query, parameters)
        return promiseWrapper('update', query, parameters)
    end,

    -- Transaction (Batch operations)
    ---@param queries string[] SQL queries
    ---@param parameters? any[] Parameters for the queries
    ---@return promise
    Transaction = function(queries, parameters)
        local p = promise.new()
        oxmysql:transaction(queries, parameters or {}, function(result)
            p:resolve(result)
        end)
        return p
    end
}