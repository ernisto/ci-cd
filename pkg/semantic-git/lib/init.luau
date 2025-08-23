local semver = require('@lpkg/semver')
export type version = semver.version

local commit = require('@self/commit')
export type commit = commit.semantic_commit

local placeholder_env = require('@config/env')
local changelog = require('@self/changelog')
local branch = require('@self/branch')

-- module
return table.freeze {
	placeholder_env = placeholder_env,
	changelog = changelog,
	version = semver,
	branch = branch,
	commit = commit,
}
