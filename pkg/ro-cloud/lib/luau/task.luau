local auth = require('@lib/auth')
local operation = require('@lib/v2/operation')

type json = auth.json

-- defs
type date = string
type task_path = string

export type error_code =
	| 'ERROR_CODE_UNSPECIFIED' --	UNSPECIFIED
	| 'SCRIPT_ERROR' --	The task's script raised an unhandled error.
	| 'DEADLINE_EXCEEDED' --	The task exceeded the maximum allowed execution duration.
	| 'OUTPUT_SIZE_LIMIT_EXCEEDED' --	The task's outputs were too large.
	| 'INTERNAL_ERROR' --	The Task failed due to an internal system error.

-- shared
type task_base = {
	path: task_path,
	user: string,
	timeout: string?,
}
type done_base = task_base & {
	createTime: date,
	updateTime: date,
}

-- per-state types
export type pending_task = task_base & {
	script: string,
	state: 'QUEUED' | 'PROCESSING',
}
export type failed_task = done_base & {
	state: 'FAILED',
	error: {
		code: error_code,
		message: string?,
	},
}
export type complete_task = done_base & {
	state: 'COMPLETE',
	output: { results: { json } },
}
export type cancelled_task = done_base & { state: 'CANCELLED' }

export type done_task = failed_task | complete_task | cancelled_task
export type task = pending_task | done_task

-- functions
export type task_input = {
	script: string,
	timeout: string?,
}
type subject = { universe_id: number, place_id: number, version: number? }
local function create(session: auth.cloud_session, subject: subject, task: task_input): pending_task
	local path = `cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}/`
	if subject.version ~= nil then
		path ..= `versions/{subject.version}/`
	end
	return auth.request_json(session, path .. 'luau-execution-session-tasks', 'POST', task) :: any
end

local function get(session: auth.cloud_session, path: task_path): task
	return auth.request_json(session, `cloud/v2/{path}`, 'GET', {}) :: any
end

local function wait_for_task(session: auth.cloud_session, path: task_path): done_task?
	return operation.poll_for_result(session, path) :: any
end

-- module
return table.freeze {
	create = create,
	get = get,
	wait_for_task = wait_for_task,
}
