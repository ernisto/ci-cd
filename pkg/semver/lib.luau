-- defs
export type raw_semver = string

export type version = {
	major: number,
	minor: number,
	patch: number,
	pre_release: { string }?,
	build_metadata: { string }?,
}

export type partial_version = {
	major: number?,
	minor: number?,
	patch: number?,
	pre_release: { string }?,
	build_metadata: { string }?,
}

-- functions
local function try_parse(input: string): version?
	local major, minor, patch, remaining = input:match('^v?(%d+)%.(%d+)%.(%d+)(.*)')
	if not remaining then return end

	if not major or major:match('^0%d$') then return end
	if not minor or minor:match('^0%d$') then return end
	if not patch or patch:match('^0%d$') then return end

	local major_num = tonumber(major)
	local minor_num = tonumber(minor)
	local patch_num = tonumber(patch)

	if not major_num or not minor_num or not patch_num then return end

	local pre_release
	local build_metadata

	local pre_release_str, next_remaining = remaining:match('^%-([^%+]+)(.*)')
	if pre_release_str then
		remaining = next_remaining
		pre_release = pre_release_str:split('.')

		for _, id in pre_release do
			if #id == 0 then return end
			if not id:match('^[%w%-]+$') then return end
		end
	end

	local build_metadata_str = remaining:match('^%+(.*)')
	if build_metadata_str then
		build_metadata = string.split(build_metadata_str, '.')
		remaining = ''
		for _, id in build_metadata :: { string } do
			if #id == 0 then return end
			if not id:match('^[%w%-]+$') then return end
		end
	end

	if remaining ~= '' then return end
	return table.freeze {
		major = major_num,
		minor = minor_num,
		patch = patch_num,
		pre_release = pre_release,
		build_metadata = build_metadata,
	}
end
local function is_valid(input: string): raw_semver?
	return try_parse(input) and input or nil
end

local function is_latest_pre_release(pre_release1: { string }?, pre_release2: { string }?): boolean
	if not pre_release1 and not pre_release2 then return false end
	if not pre_release1 then return true end
	if not pre_release2 then return false end

	for i = 1, math.min(#pre_release1, #pre_release2) do
		local id1 = pre_release1[i]
		local id2 = pre_release2[i]
		local num1 = tonumber(id1)
		local num2 = tonumber(id2)
		if num1 and not num2 then return false end
		if num2 and not num1 then return true end
		if num1 and num2 and num1 ~= num2 then return num1 > num2 end
		if id1 ~= id2 then return id1 > id2 end
	end
	return #pre_release1 > #pre_release2
end

-- constructors
local function new_from(version: version, patch: partial_version): version
	return table.freeze {
		major = patch.major or version.major,
		minor = patch.minor or version.minor,
		patch = patch.patch or version.patch,
		pre_release = if #(patch.pre_release or {}) > 0 then patch.pre_release else version.pre_release,
		build_metadata = if #(patch.build_metadata or {}) > 0 then patch.build_metadata else version.build_metadata,
	}
end

local function parse(input: string): version
	return try_parse(input) or error(`couldnt parse version '{input}'`)
end

-- methods
local function is_latest(version1: version, version2: version): boolean
	return if version1.major ~= version2.major
		then version1.major > version2.major
		elseif version1.minor ~= version2.minor then version1.minor > version2.minor
		elseif version1.patch ~= version2.patch then version1.patch > version2.patch
		else is_latest_pre_release(version1.pre_release, version2.pre_release)
end

local function is_oldest(version1: version, version2: version): boolean
	return not is_latest(version1, version2)
end

local function tostring(version: version)
	return `{version.major}.{version.minor}.{version.patch}`
		.. (if version.pre_release then '-' .. table.concat(version.pre_release, '.') else '')
		.. (if version.build_metadata then '+' .. table.concat(version.build_metadata, '.') else '')
end

-- module
return table.freeze {
	is_valid = is_valid,
	new_from = new_from,
	try_parse = try_parse,
	parse = parse,

	is_oldest = is_oldest,
	is_latest = is_latest,
	tostring = tostring,
}
