local auth = require('@lib/auth')

-- defs
type date = string
type social_link = { title: string?, uri: string? }

type age_rating =
	| 'AGE_RATING_UNSPECIFIED'
	| 'AGE_RATING_ALL'
	| 'AGE_RATING_9_PLUS'
	| 'AGE_RATING_13_PLUS'
	| 'AGE_RATING_17_PLUS'

type visibility =
	| 'VISIBILITY_UNSPECIFIED'
	| 'PUBLIC' --	The universe is public.
	| 'PRIVATE' --	The universe is private. All active players are immediately removed from all running servers.

-- shared
type universe_social_links = {
	facebookSocialLink: social_link?,
	twitterSocialLink: social_link?,
	youtubeSocialLink: social_link?,
	twitchSocialLink: social_link?,
	discordSocialLink: social_link?,
	robloxGroupSocialLink: social_link?,
	guildedSocialLink: social_link?,
}
type universe_platform_flags = {
	voiceChatEnabled: boolean?,
	desktopEnabled: boolean?,
	mobileEnabled: boolean?,
	tabletEnabled: boolean?,
	consoleEnabled: boolean?,
	vrEnabled: boolean?,
}

-- per-function types
export type universe_patch = universe_social_links & universe_platform_flags & {
	privateServerPriceRobux: number?,
}
export type universe = universe_social_links & universe_platform_flags & {
	path: string,
	createTime: date,
	updateTime: date,
	displayName: string,
	description: string,
	user: string?,
	group: string?,
	visibility: visibility,
	ageRating: age_rating,
	rootPlace: string,
	privateServerPriceRobux: number?,
}
export type message = { topic: string, message: string }

-- functions
local function get(session: auth.cloud_session, universe_id: number): universe
	return auth.request_json(session, `cloud/v2/universes/{universe_id}`, 'GET') :: any
end
local function update(session: auth.cloud_session, universe_id: number, patch: universe_patch): universe
	return auth.request_json(session, `cloud/v2/universes/{universe_id}`, 'PATCH', patch) :: any
end
local function publish_message(session: auth.cloud_session, universe_id: number, message: message)
	return auth.request_json(session, `cloud/v2/universes/{universe_id}:publishMessage`, 'POST', message)
end
local function shutdown(session: auth.cloud_session, universe_id: number)
	return auth.request_json(session, `cloud/v2/universes/{universe_id}:restartServers`, 'POST')
end

-- module
return table.freeze {
	get = get,
	update = update,
	publish_message = publish_message,
	shutdown = shutdown,
}
