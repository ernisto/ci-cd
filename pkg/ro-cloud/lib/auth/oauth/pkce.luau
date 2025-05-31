local serde = require('@lune/serde')
local base64 = require('@utils/base64')
local bytes = require('@utils/bytes')

-- functions
type base64_url_str = string
local function for_url(str: base64.base64_str): base64_url_str
	return str:gsub('%+', '-'):gsub('/', '_'):gsub('=', '')
end
local function generate_code_verifier(): base64_url_str
	return for_url(base64.encode(bytes.random(32)))
end

local code_challenge = {}

function code_challenge.S256(verifier: base64_url_str): base64_url_str
	local hash = serde.hash('sha256', verifier)
	return for_url(base64.encode(bytes.from_hex_str(hash)))
end
function code_challenge.plain(verifier: base64_url_str): base64_url_str
	return verifier
end

-- module
return table.freeze {
	generate_code_verifier = generate_code_verifier,
	generate_code_challenge = code_challenge,
}
