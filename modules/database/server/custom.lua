return {
    -- Fetch multiple rows
    Select = function(query, parameters)
        return {}
    end,

    -- Fetch single value
    Scalar = function(query, parameters)
        return 0
    end,

    -- Insert row (Returns ID)
    Insert = function(query, parameters)
        return 0
    end,

    -- Update/Delete (Returns affected rows count)
    Update = function(query, parameters)
        return 0
    end,

    -- Transaction (Batch operations)
    Transaction = function(queries, parameters)
        return 0
    end
}