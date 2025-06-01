local serde = require('@lune/serde')
local auth = require('@lib/auth')

-- defs
export type place = {
	path: string,
	displayName: string,
	description: string,
	serverSize: number,
}
export type place_output = place & {
	createTime: string,
	updateTime: string,
}

-- functions
type result = { versionNumber: number }
local function publish(
	session: auth.session,
	universe_id: number,
	place_id: number,
	raw_place_file: buffer,
	do_publish: boolean?
): result
	local json = auth.request(
		session,
		`universes/v1/{universe_id}/places/{place_id}/versions?versionType={if do_publish then 'Published' else 'Saved'}`,
		'POST',
		'application/octet-stream',
		raw_place_file
	)
	return serde.decode('json', json)
end

-- module
return table.freeze {
	publish = publish,
}
