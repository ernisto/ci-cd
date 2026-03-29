local roblox = require('@lune/roblox')
local net = require('@lune/net')

-- defs
export type session = { api_key: nil, cookie: string }

-- functions
local function login(cookie: string?): session
	if not cookie then
		warn('no cookie provided, getting your local cookie')
		cookie = roblox.getAuthCookie()
	end
	assert(cookie, `couldnt possible login`)
	return table.freeze {
		cookie = cookie,
	}
end

-- methods
local API_ENDPOINT = 'https://apis.roblox.com/'
local function request(
	session: session,
	path: string,
	method: net.HttpMethod,
	content_type: string, -- unknown
	data: string | buffer?
)
	return net.request({
		url = API_ENDPOINT .. path,
		method = method,
		body = data,
		headers = {
			['Content-Type'] = content_type,
			['Cookie'] = `.ROBLOSECURITY={session.cookie}`,
		},
	})
end

-- module
return table.freeze {
	request = request,
	login = login,
}
