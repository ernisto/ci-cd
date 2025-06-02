local fs = require('@lune/fs')

local env = require('@utils/env')
local git = require('@pkg/git/lib')
local rocloud = require('@pkg/ro-cloud/lib')
local semantic_git = require('@pkg/semantic-git/lib')
local semver = semantic_git.version

-- environment
local api_key = env.get 'API_KEY' or error 'couldnt get api key'
local session = rocloud.auth.api.login(api_key)

local raw_place_file = buffer.fromstring(fs.readFile 'game.rbxl')
local universe_id = env.get_number 'UNIVERSE_ID' or error 'couldnt get universe id in environment variables'
local place_id = env.get_number 'PLACE_ID' or error 'couldnt get place id in environment variables'

-- init
local current_branch = git.head.read_current()
local prev_version, post_commit_ids = semantic_git.branch.get_prev_version(current_branch)
assert(prev_version, `couldnt possible get current version`)

local new_version = semantic_git.branch.get_next_version(current_branch, prev_version, post_commit_ids)
if not new_version then
	warn(`no relevant updates for a new version`)
	return nil
end

-- generate changelogs
local authors = {}
local commits = {}
for _, commit_id in post_commit_ids do
	local commit = git.commit.read_from_id(commit_id)
	table.insert(commits, commit)
	authors[commit.author.email] = commit.author.name
end

local last_commit_id = commits[#commits].parent_ids[1]
local changelog_env = semantic_git.placeholder_env:extends {
	version = semver.tostring(new_version or prev_version),
	last_version = semver.tostring(prev_version),

	semantic_commits = semantic_git.commit.index_commits_by_kind(post_commit_ids),
	last_commit = last_commit_id and git.commit.read_from_id(last_commit_id),

	commits = commits,
	authors = authors,
}
semantic_git.changelog.write(changelog_env, 'CHANGELOG.md')

-- publish
local universe = rocloud.universe.place.publish(session, universe_id, place_id, raw_place_file)
print(universe)

-- run unit tests
local task_session = rocloud.luau.task.create(
	session,
	{ universe_id = universe_id, place_id = place_id, version = universe.versionNumber },
	{
		script = 'print("starting"); task.wait(5); print("done")',
		timeout = '3s',
		binaryInput = 'string',
		enableBinaryOutput = true,
	}
)
print('started task', task_session)

local task_log = rocloud.luau.task_log.list(session, task_session.path, { max_page_size = 100 })
print('task logs', task_log)

local done_task = rocloud.luau.task.wait_for_task(session, task_session.path)
print('task done', done_task)
-- task.wait(6)

local done_task_log = rocloud.luau.task_log.list(session, task_session.path, { max_page_size = 100 })
print('task logs', done_task_log)

print('new_version', semver.tostring(new_version or prev_version), new_version or prev_version)

return nil
