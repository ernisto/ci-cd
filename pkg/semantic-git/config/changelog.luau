local serde = require('@lune/serde')
local file = require('@utils/file')

-- defs
local default_content = file.read_str_asset(`../semantic-changelog.yaml`)

-- functions
local function get_or_create()
	local raw = file.read_or_create('.github/semantic-changelog.yaml', default_content)
	return serde.decode('yaml', raw)
end

-- module
return table.freeze {
	get_or_create = get_or_create,
}
