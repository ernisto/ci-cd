local placeholder_env = require('@self/env')
export type placeholder = placeholder_env.placeholder
export type env = placeholder_env.env

return table.freeze {
	change_log = require('@self/changelog'),
	versions = require('@self/versions'),
	commits = require('@self/commits'),
	env = placeholder_env,
}
