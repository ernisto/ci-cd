local auth = require('@lib/auth')

-- defs
type date = string
type social_link = {
	title: string,
	uri: string,
}
type age_rating =
	| 'AGE_RATING_UNSPECIFIED' --	The age rating is not set.
	| 'AGE_RATING_ALL' --	Supported for all users.
	| 'AGE_RATING_9_PLUS' --	Supported for users aged 9 and up.
	| 'AGE_RATING_13_PLUS' --	Supported for users aged 13 and up.
	| 'AGE_RATING_17_PLUS' --	Supported for users aged 17 and up.

type visibility =
	| 'VISIBILITY_UNSPECIFIED' --	Updates using this value will throw an error on the backend.
	| 'PUBLIC' --	The universe is public.
	| 'PRIVATE' --	The universe is private. If a universe's visibility is set to PRIVATE, all active players will immediately be removed from all running servers.

export type universe_input = {
	privateServerPriceRobux: number,

	facebookSocialLink: social_link,
	twitterSocialLink: social_link,
	youtubeSocialLink: social_link,
	twitchSocialLink: social_link,
	discordSocialLink: social_link,
	robloxGroupSocialLink: social_link,
	guildedSocialLink: social_link,

	voiceChatEnabled: boolean,
	desktopEnabled: boolean,
	mobileEnabled: boolean,
	tabletEnabled: boolean,
	consoleEnabled: boolean,
	vrEnabled: boolean,
}
export type universe_output = universe_input & {
	path: string,
	createTime: date,
	updateTime: date,
	displayName: string,
	description: string,
	user: string,
	group: string,
	visibility: string,
	ageRating: string,
}

-- functions
local function get(session: auth.session, universe_id: number): universe_output
	return auth.request_json(session, `cloud/v2/universes/{universe_id}`, 'GET', {}) :: any
end
local function update(session: auth.session, universe_id: number, patch: universe_input): universe_output
	return auth.request_json(session, `cloud/v2/universes/{universe_id}`, 'PATCH', patch) :: any
end
local function publish_message(session: auth.session, universe_id: number, topic: string, message: string)
	return auth.request_json(
		session,
		`cloud/v2/universes/{universe_id}:publishMessage`,
		'POST',
		{ topic = topic, message = message }
	)
end
local function shutdown(session: auth.session, universe_id: number)
	return auth.request_json(session, `cloud/v2/universes/{universe_id}:restartServers`, 'POST', {})
end

-- module
return table.freeze {
	get = get,
	update = update,
	publish_message = publish_message,
	shutdown = shutdown,
}
