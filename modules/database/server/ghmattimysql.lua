local ghmattimysql = exports.ghmattimysql

local function promiseWrapper(method, query, parameters)
    local p = promise.new()
    ghmattimysql[method](ghmattimysql, query, parameters or {}, function(result)
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
        return promiseWrapper('execute', query, parameters)
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
        local p = promise.new()
        ghmattimysql:execute(query, parameters or {}, function(result)
            p:resolve(result and result.insertId or 0)
        end)
        return p
    end,

    -- Update/Delete (Returns affected rows count)
    ---@param query string SQL query
    ---@param parameters? any[] Parameters for the query
    ---@return promise
    Update = function(query, parameters)
        local p = promise.new()
        ghmattimysql:execute(query, parameters or {}, function(result)
            p:resolve(result and result.affectedRows or 0)
        end)
        return p
    end,

    -- Transaction (Batch operations)
    ---@param queries string[] SQL queries
    ---@param parameters? any[] Parameters for the queries
    ---@return promise
    Transaction = function(queries, parameters)
        local p = promise.new()
        ghmattimysql:transaction(queries, function(result)
            p:resolve(result)
        end)
        return p
    end
}
