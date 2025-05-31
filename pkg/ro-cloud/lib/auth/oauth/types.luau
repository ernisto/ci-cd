-- Constants
export type permission = 'openid' | 'profile'

export type session = {
	access_token: string,
	refresh_token: string,
	token_type: 'Bearer' | string,
	expires_in: number,
	id_token: string?,
	scope: { permission },
	-- Additional fields for session management
	created_at: number,
	expires_at: number,
}

export type oauth_error = {
	error: string,
	error_description: string?,
	error_uri: string?,
}

-- Endpoints
local endpoints = {
	AUTH = 'https://apis.roblox.com/oauth/v1/authorize',
	TOKEN = 'https://apis.roblox.com/oauth/v1/token',
	API = 'https://apis.roblox.com/',
}

return table.freeze(endpoints) 