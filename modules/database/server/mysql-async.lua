local MySQL = exports['mysql-async']

return {
    -- Fetch multiple rows
    ---@param query string SQL query
    ---@param parameters? any[] Parameters for the query
    ---@return promise
    Select = function(query, parameters)
        local p = promise.new()
        MySQL:mysql_fetch_all(query, parameters or {}, function(result)
            p:resolve(result)
        end)
        return p
    end,

    -- Fetch single value
    ---@param query string SQL query
    ---@param parameters? any[] Parameters for the query
    ---@return promise
    Scalar = function(query, parameters)
        local p = promise.new()
        MySQL:mysql_fetch_scalar(query, parameters or {}, function(result)
            p:resolve(result)
        end)
        return p
    end,

    -- Insert row (Returns ID)
    ---@param query string SQL query
    ---@param parameters? any[] Parameters for the query
    ---@return promise
    Insert = function(query, parameters)
        local p = promise.new()
        MySQL:mysql_insert(query, parameters or {}, function(result)
            p:resolve(result)
        end)
        return p
    end,

    -- Update/Delete (Returns affected rows count)
    ---@param query string SQL query
    ---@param parameters? any[] Parameters for the query
    ---@return promise
    Update = function(query, parameters)
        local p = promise.new()
        MySQL:mysql_execute(query, parameters or {}, function(result)
            p:resolve(result)
        end)
        return p
    end,

    -- Transaction (Batch operations)
    ---@param queries string[] SQL queries
    ---@param parameters? any[] Parameters for the queries
    ---@return promise
    Transaction = function(queries, parameters)
        local p = promise.new()
        MySQL:mysql_transaction(queries, parameters or {}, function(result)
            p:resolve(result)
        end)
        return p
    end
}