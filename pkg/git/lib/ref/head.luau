local read_descendant_paths = require('@utils/read_descendant_paths')
local task = require('@lune/task')
local fs = require('@lune/fs')

local types = require('@lib/types')
local warns = require('@lib/warns')
local ref = require('@lib/ref')

-- functions
local function read_from_id(path: types.ref_id): types.head
	return ref.read_from_id(path) :: any
end
local function read_from_name(name: string): types.head
	return read_from_id('refs/heads/' .. name)
end
local function read_current(): types.head
	local id = fs.readFile('.git/HEAD'):match('^ref: (%S+)') or error(`couldnt possible read HEAD`)

	return read_from_id(id)
end

local function read_all(): { [string]: types.head }
	local heads = table.clone(ref.load_packeds().heads)
	local head_paths = read_descendant_paths('.git/refs/heads', 'refs/heads')
	warns.so_many_ref_files(#head_paths, 'heads')

	local remaining = 0
	for _, path in head_paths do
		remaining += 1
		task.spawn(function()
			local head = read_from_id(path)
			heads[head.name] = head
			remaining -= 1
		end)
	end
	while remaining > 0 do
		task.wait()
	end
	return heads
end

-- module
return table.freeze({
	read_from_name = read_from_name,
	read_from_id = read_from_id,

	read_current = read_current,
	read_all = read_all,
})
