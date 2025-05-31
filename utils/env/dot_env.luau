-- defs
export type env = { [string]: string? }

-- functions
local function parse_env_line(line: string): (string?, string?)
	line = string.match(line, '^[^#]*') or ''

	line = string.gsub(line, '^%s*(.-)%s*$', '%1')
	if line == '' then return nil, nil end

	local key, value = string.match(line, '^([%w_]+)%s*=%s*(.+)$')
	if not key or not value then return nil, nil end

	value = string.match(value, '^"(.-)"$') or string.match(value, "^'(.-)'$") or value
	return key, value
end

local function parse_env(content)
	local env_vars = {}

	for line in string.gmatch(content, '[^\r\n]+') do
		local key, value = parse_env_line(line)
		if key then env_vars[key] = value end
	end

	return env_vars
end

-- module
return table.freeze {
	parse = parse_env,
}
