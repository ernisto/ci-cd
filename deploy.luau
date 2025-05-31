local git = require('pkg/git/lib')
local rocloud = require('pkg/ro-cloud/lib')
local semantic_git = require('pkg/semantic-git/lib')
local semver = semantic_git.version

-- init
local current_branch = git.head.read_current()
local prev_version, post_commit_ids = semantic_git.branch.get_prev_version(current_branch)
assert(prev_version, `couldnt possible get current version`)

local new_version = semantic_git.branch.get_next_version(current_branch, prev_version, post_commit_ids)
if not new_version then
	warn(`no relevant updates for a new version`)
	return nil
end

-- get context for changelog
local authors = {}
local commits = {}
for _, commit_id in post_commit_ids do
	local commit = git.commit.read_from_id(commit_id)
	table.insert(commits, commit)
	authors[commit.author.email] = commit.author.name
end

local last_commit_id = commits[#commits].parent_ids[1]
local env = semantic_git.placeholder_env:extends {
	version = semver.tostring(new_version or prev_version),
	last_version = semver.tostring(prev_version),

	semantic_commits = semantic_git.commit.index_commits_by_kind(post_commit_ids),
	last_commit = last_commit_id and git.commit.read_from_id(last_commit_id),

	commits = commits,
	authors = authors,
}
semantic_git.changelog.write(env, 'CHANGELOG.md')

local session = rocloud.auth.api.login(api_key, {})

print('new_version', semver.tostring(new_version or prev_version), new_version or prev_version)

return nil
