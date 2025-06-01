local task = require('@lune/task')
local auth = require('@lib/auth')
type json = auth.json

-- defs
local BASE_OPERATION_URL = 'https://apis.roblox.com/cloud/v2/'

export type operation<Result, Metadata> = pending_operation | done_operation<Result, Metadata>
export type pending_operation = {
	path: string, -- The endpoint path to call to poll for the request's completion. Append the path to the original base URL of the resource method.
	done: false,
	response: nil,
	metadata: nil,
}
export type done_operation<Result = json, Metadata = json> = {
	path: string,
	done: true,
	response: Result,
	metadata: Metadata,
}

-- functions
local function get_operation<Result, Metadata>(session: auth.session, operation_path: string): operation<Result, Metadata>
	return auth.request_json(session, BASE_OPERATION_URL .. operation_path, 'GET', {}) :: any
end
local function poll_for_result<Result, Metadata>(session: auth.session, operation_path: string): done_operation<Result, Metadata>?
	local retry_polling_multiplier = 2
	local retry_polling_delay = 1

	for attempt = 1, 10 do
		if attempt > 1 then task.wait(retry_polling_delay) end

		local success, operation = pcall(get_operation, session, operation_path)
		retry_polling_delay *= retry_polling_multiplier

		if not success then warn(operation) end
		if operation.done then return operation end
	end
	return
end

-- module
return table.freeze {
	get_operation = get_operation,
	poll_for_result = poll_for_result,
}
