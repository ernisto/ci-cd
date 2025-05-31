local serde = require('@lune/serde')
local net = require('@lune/net')

local oauth = require('@self/oauth')
export type oauth_session = oauth.session

local user = require('@self/user')
export type user_session = user.session

local api = require('@self/api')
export type api_session = api.session

-- defs
export type session = oauth_session | user_session | api_session
export type json = number | boolean | string | { json } | json_object
export type json_object = { [string]: json }

-- functions
local function request(
	session: session,
	path: string,
	method: net.HttpMethod,
	content_type: string,
	data: string | buffer
): string
	return if (session :: any).api_key
		then api.request(session :: any, path, method, content_type, data)
		elseif (session :: any).cookie then user.request(session :: any, path, method, content_type, data)
		else oauth.request(session :: any, path, method, content_type, data)
end

local function request_json(session: session, path: string, method: net.HttpMethod, data: json_object): json_object
	local response_body = request(session, path, method, serde.encode('json', data), 'application/json')
	return serde.decode('json', response_body)
end

-- module
return table.freeze {
	request_json = request_json,
	request = request,

	oauth = oauth,
	user = user,
	api = api,
}
