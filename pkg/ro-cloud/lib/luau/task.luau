local auth = require('@lib/auth')
local operation = require('@lib/v2/operation')

type json = auth.json

-- defs
type date = string
type task_path = string

export type state =
	| 'STATE_UNSPECIFIED' --	UNSPECIFIED
	| 'QUEUED' --	The Task is waiting to be processed.
	| 'PROCESSING' --	The Task has been picked up for processing.
	| 'CANCELLED' --	The Task has been stopped by the user.
	| 'COMPLETE' --	The Task has finished processing. The output field contains the output.
	| 'FAILED' --	The Task failed. The error field contains details about the error.

export type error_code =
	| 'ERROR_CODE_UNSPECIFIED' --	UNSPECIFIED
	| 'SCRIPT_ERROR' --	The task's script raised an unhandled error.
	| 'DEADLINE_EXCEEDED' --	The task exceeded the maximum allowed execution duration.
	| 'OUTPUT_SIZE_LIMIT_EXCEEDED' --	The task's outputs were too large.
	| 'INTERNAL_ERROR' --	The Task failed due to an internal system error?,

export type task_input = {
	script: string,
	timeout: string?,
	binaryInput: string?,
	enableBinaryOutput: boolean?,
}
type base_task = task_input & {
	path: task_path,
	createTime: date,
	updateTime: date,
	user: string,
	binaryOutputUri: string?,
}

export type task = pending_task | complete_task | failed_task | cancelled_task
export type pending_task = base_task & { state: 'QUEUED' | 'PROCESSING' }
export type cancelled_task = base_task & { state: 'CANCELLED' }
export type failed_task = base_task & {
	state: 'FAILED',
	error: {
		message: string?,
		code: error_code,
	}?,
}
export type complete_task = base_task & {
	state: 'COMPLETE',
	output: { json },
}

-- functions
type subject = { universe_id: number, place_id: number, version: number? }
local function create(session: auth.session, subject: subject, task: task_input): task
	local path = `cloud/v2/universes/{subject.universe_id}/places/{subject.place_id}/`
	if subject.version ~= nil then
		path ..= `versions/{subject.version}/`
	end
	return auth.request_json(session, path .. 'luau-execution-session-tasks', 'POST', task :: any) :: any
end

local function get(session: auth.session, task_path: task_path): task
	return auth.request_json(session, `cloud/v2/{task_path}`, 'GET', {}) :: any
end

local function wait_for_task(session: auth.session, operation_path: string): operation.done_operation<task, json>?
	return operation.poll_for_result(session, operation_path)
end

-- module
return table.freeze {
	create = create,
	get = get,
	wait_for_task = wait_for_task,
}
