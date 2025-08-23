local fs = require('@lune/fs')
local task = require('@lune/task')

export type path = string
type ptr<T> = { T }

local function spawn_read_descendants_paths(path: string, local_path: string, out: { string }, remaining: ptr<number>)
	for _, name in fs.readDir(path) do
		remaining[1] += 1
		task.spawn(function()
			if fs.isFile(path .. '/' .. name) then
				table.insert(out, local_path .. '/' .. name)
			else
				spawn_read_descendants_paths(path .. '/' .. name, local_path .. '/' .. name, out, remaining)
			end
			remaining[1] -= 1
		end)
	end
end

local function read_descendants_paths_handle(path: path, local_path: path?): { path }
	local_path = local_path or ''
	assert(local_path)

	local remaining = { 0 }
	local out = {}

	spawn_read_descendants_paths(path, local_path, out, remaining)
	while remaining[1] > 0 do
		task.wait()
	end

	return out
end

return read_descendants_paths_handle
