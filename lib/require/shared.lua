--[[
    Adapted from ox_lib (https://github.com/overextended/ox_lib)
    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>
    Copyright © 2025 Linden <https://github.com/thelindat>

    Adapted for div_bridge: returns a callable require table (dLib.require),
    resolves the resource via GetCurrentResourceName() (no bare `cache` global
    dependency), and keeps the package shim local instead of clobbering the
    standard `package` global.
]]

local loaded = {}
local _require = require
local function noop() end

-- Local package shim (not published as a global).
local package = {
    path = './?.lua;./?/init.lua',
    preload = {},
    loaded = setmetatable({}, {
        __index = loaded,
        __newindex = noop,
        __metatable = false,
    })
}

---Resolves the owning resource and normalised module path for a module name.
---`@resource/module` targets a remote resource; otherwise the caller's resource
---is inferred from the Lua call stack.
---@param modName string
---@return string resource
---@return string modName
local function getModuleInfo(modName)
    local resource = modName:match('^@(.-)/.+') --[[@as string?]]

    if resource then
        return resource, modName:sub(#resource + 3)
    end

    local idx = 4 -- call stack depth (kept slightly lower than expected depth "just in case")

    while true do
        local src = debug.getinfo(idx, 'S')?.source

        if not src then
            return GetCurrentResourceName(), modName
        end

        resource = src:match('^@@([^/]+)/.+')

        if resource and not src:find('^@@div_bridge/lib/require') then
            return resource, modName
        end

        idx += 1
    end
end

local tempData = {}

---@param name string
---@param path string
---@return string? filename
---@return string? errmsg
local function searchpath(name, path)
    local resource, modName = getModuleInfo(name:gsub('%.', '/'))
    local tried = {}

    for template in path:gmatch('[^;]+') do
        local fileName = template:gsub('^%./', ''):gsub('?', modName:gsub('%.', '/') or modName)
        local file = LoadResourceFile(resource, fileName)

        if file then
            tempData[1] = file
            tempData[2] = resource
            return fileName
        end

        tried[#tried + 1] = ("no file '@%s/%s'"):format(resource, fileName)
    end

    return nil, table.concat(tried, "\n\t")
end

package.searchpath = searchpath

---Attempts to load a module at the given path relative to the resource root.
---Returns a function to run the module chunk, or a string of tested paths.
---@param modName string
---@param env? table
---@return function? chunk
---@return string filenameOrErr
local function loadModule(modName, env)
    local fileName, err = searchpath(modName, package.path)

    if fileName then
        local file = tempData[1]
        local resource = tempData[2]

        tempData[1] = nil
        tempData[2] = nil
        return assert(load(file, ('@@%s/%s'):format(resource, fileName), 't', env or _ENV)), fileName
    end

    return nil, err or 'unknown error'
end

---@type (fun(modName: string): function|nil, string?)[]
package.searchers = {
    function(modName)
        local ok, result = pcall(_require, modName)
        if ok then return result end
        return nil, result
    end,
    function(modName)
        if package.preload[modName] ~= nil then
            return package.preload[modName]
        end
        return nil, ("no field package.preload['%s']"):format(modName)
    end,
    function(modName) return loadModule(modName) end,
}

---Loads and runs a Lua file at the given path. The chunk is NOT cached.
---@param filePath string
---@param env? table
---@return unknown
local function load_(filePath, env)
    if type(filePath) ~= 'string' then
        error(("file path must be a string (received '%s')"):format(filePath), 2)
    end

    local chunk, err = loadModule(filePath, env)
    if chunk then return chunk() end

    error(("file '%s' not found\n\t%s"):format(filePath, err))
end

---Loads and decodes a json file at the given path.
---@param filePath string
---@return table
local function loadJson(filePath)
    if type(filePath) ~= 'string' then
        error(("file path must be a string (received '%s')"):format(filePath), 2)
    end

    local resourceSrc, modPath = getModuleInfo(filePath:gsub('%.', '/'))
    local resourceFile = LoadResourceFile(resourceSrc, ('%s.json'):format(modPath))

    if resourceFile then
        return json.decode(resourceFile)
    end

    error(("json file '%s' not found\n\tno file '@%s/%s.json'"):format(filePath, resourceSrc, modPath))
end

---Loads the given module, returning any value it returns (`true` when `nil`).
---Cached for future calls. Use `@resourceName/modName` for a remote resource.
---@param modName string
---@return unknown
local function require(modName)
    if type(modName) ~= 'string' then
        error(("module name must be a string (received '%s')"):format(modName), 3)
    end

    local module = loaded[modName]

    if module == '__loading' then
        error(("^1circular-dependency occurred when loading module '%s'^0"):format(modName), 2)
    end

    if module ~= nil then return module end

    loaded[modName] = '__loading'

    local err = {}

    for i = 1, #package.searchers do
        local loader, data = package.searchers[i](modName)

        if loader then
            if type(loader) == 'function' then loader = loader(modName, data) end
            loaded[modName] = loader or loader == nil
            return loaded[modName]
        end

        err[#err + 1] = data
    end

    loaded[modName] = nil
    error(("%s"):format(table.concat(err, "\n\t")))
end

-- dLib.require is callable directly (dLib.require('path')) and also exposes
-- the loader helpers: dLib.require.load(path[, env]) and dLib.require.loadJson(path).
return setmetatable({
    load = load_,
    loadJson = loadJson,
}, {
    __call = function(_, modName) return require(modName) end,
})
