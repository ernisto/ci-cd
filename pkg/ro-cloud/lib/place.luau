local serde = require('@lune/serde')
local auth = require('@lib/auth')

-- functions
type subject = { universe_id: number, place_id: number }
type result = { versionNumber: number }

local function upload(session: auth.cloud_session, subject: subject, file: buffer, do_publish: boolean?): result
	local res = auth.request(
		session,
		`universes/v1/{subject.universe_id}/places/{subject.place_id}/versions?versionType={if do_publish
			then 'Published'
			else 'Saved'}`,
		'POST',
		'application/octet-stream',
		file
	)
	return serde.decode('json', res.body)
end

-- module
return table.freeze {
	upload = upload,
}
