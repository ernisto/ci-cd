local file = require('@utils/file')
local serde = require('@lune/serde')

-- def
local default_content = file.read_str_asset(`../semantic-commit.yaml`)

-- functions
local function get_or_create()
	local raw = file.read_or_create('.github/semantic-commit.yaml', default_content)
	return serde.decode('yaml', raw)
end

-- module
return table.freeze {
	get_or_create = get_or_create,
}
