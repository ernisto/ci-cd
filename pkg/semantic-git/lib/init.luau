local version = require('@self/version')
export type version = version.version

local commit = require('@self/commit')
export type commit = commit.semantic_commit

local placeholder_env = require('@config/env')
local changelog = require('@self/changelog')
local branch = require('@self/branch')

-- module
return table.freeze {
	placeholder_env = placeholder_env,
	changelog = changelog,
	version = version,
	branch = branch,
	commit = commit,
}
