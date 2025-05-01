-- defs
export type session = {}

-- functions
local function login(): session
	return table.freeze {}
end

-- module
return table.freeze {
	login = login,
}
