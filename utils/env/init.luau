local process = require('@lune/process')
local dot_env = require('@self/dot_env')
local fs = require('@lune/fs')

local env_file: dot_env.env?

-- functions
local function load(path: string?): dot_env.env
	if env_file then return env_file end
	local env_path = path or './.env'

	local content = fs.isFile(env_path) and fs.readFile(env_path) or nil
	env_file = content and dot_env.parse(content) or {}

	return env_file :: any
end

local function get(name: string): string?
	return load()[name] or process.env[name]
end
local function get_number(name: string): number?
	return tonumber(get(name) or '')
end

-- module
return table.freeze {
	get_number = get_number,
	get = get,
}
