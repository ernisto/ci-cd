local net = require('@lune/net')

-- defs
export type session = { api_key: string }

-- functions
local function login(api_key: string): session
	return table.freeze {
		api_key = api_key,
	}
end

-- methods
local API_ENDPOINT = 'https://apis.roblox.com/'
local function request(
	session: session,
	path: string,
	method: net.HttpMethod,
	content_type: string, -- unknown
	data: string | buffer
): string
	local response = net.request({
		url = API_ENDPOINT .. path,
		method = method,
		body = data,
		headers = {
			['Content-Type'] = content_type,
			['x-api-key'] = session.api_key,
		},
	})
	assert(response.ok and response.statusCode == 200, `HTTP [{response.statusCode}]: {response.statusMessage}`)
	return response.body
end

-- module
return table.freeze {
	login = login,
	request = request,
}
