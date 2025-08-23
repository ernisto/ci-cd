local fs = require('@lune/fs')

-- defs
type path = string

-- functions
local function read_str_asset(path: path): string
	local caller = debug.info(2, 's')
	if fs.isFile(caller) then caller:match('(.*)/[^/]+$') end

	local abs_path = `{caller}/{path}`
	return fs.readFile(abs_path) or error(`asset not found at '{abs_path}'`)
end

local function read_or_create(path: path, default_content: string): (string, string?)
	local ancestors = string.split(path, '/')
	local file_name = table.remove(ancestors) or error(`no path provided`)

	local safe_dir = ''
	local missing_dir

	for index, name in ancestors do
		safe_dir ..= name .. '/'
		if missing_dir == nil and fs.isDir(safe_dir) then continue end

		missing_dir = path:sub(#safe_dir - #name)
		fs.writeDir(safe_dir)
	end
	safe_dir ..= file_name

	if missing_dir == nil and fs.isFile(safe_dir) then return fs.readFile(safe_dir) end
	fs.writeFile(safe_dir, default_content)

	warn(
		`Could not possible find config '{path}'. A default config was been created (missing {missing_dir or file_name})`
	)
	return default_content
end

-- module
return table.freeze {
	read_or_create = read_or_create,
	read_str_asset = read_str_asset,
}
