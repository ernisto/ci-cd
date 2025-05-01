local process = require('@lune/process')
local git = require('@pkg/git')
local fs = require('@lune/fs')

local read_or_create = require('@utils/read_or_create')

local TEMP_DIR = '.git/temp'
-- fs.removeDir(TEMP_DIR)

-- init
local branch = git.head.read_current()
local commit = git.commit.read_from_id(branch.commit_id)
local tree = git.tree.read_from_id(commit.tree_id)
local index = git.index.read_local()

local staged_file_entries = git.query.staged_files(index, tree)
local luau_staged_file_paths = {}
for _, entry in staged_file_entries do
	if not entry.path:match('%.luau$') then continue end

	local temp_file = `{TEMP_DIR}/{entry.path}`
	local blob = git.blob.read_from_id(entry.object_id)

	read_or_create(temp_file, blob.content)

	process.spawn('stylua', { temp_file }, {})
	table.insert(luau_staged_file_paths, entry.path)
end

print(luau_staged_file_paths)
