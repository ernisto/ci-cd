local semver = require('./lib')

-- Test framework helpers
local test_count = 0
local passed_count = 0

local function test(name, fn)
	test_count += 1
	print(`\n🧪 Test {test_count}: {name}`)

	local success, err = pcall(fn)
	if success then
		passed_count += 1
		print('✅ PASSED')
	else
		print(`❌ FAILED: {err}`)
	end
end

local function assert_equal(actual, expected, message: string?)
	if actual ~= expected then error(message or `Expected {expected}, got {actual}`) end
end

local function assert_nil(value, message: string?)
	if value ~= nil then error(message or `Expected nil, got {value}`) end
end

local function assert_not_nil(value, message: string?)
	if value == nil then error(message or 'Expected non-nil value') end
end

local function assert_table_equal(actual, expected, message: string?)
	if #actual ~= #expected then error(message or `Expected table length {#expected}, got {#actual}`) end

	for i = 1, #expected do
		if actual[i] ~= expected[i] then error(message or `Expected table[{i}] = {expected[i]}, got {actual[i]}`) end
	end
end

-- Spec 1: A normal version number MUST take the form X.Y.Z
test('Basic version format X.Y.Z', function()
	local version = semver.parse('1.2.3')
	assert_equal(version.major, 1)
	assert_equal(version.minor, 2)
	assert_equal(version.patch, 3)
	assert_nil(version.pre_release)
	assert_nil(version.build_metadata)
end)

-- Spec 2: X, Y, and Z are non-negative integers
test('Non-negative integers', function()
	local version = semver.parse('0.0.0')
	assert_equal(version.major, 0)
	assert_equal(version.minor, 0)
	assert_equal(version.patch, 0)
end)

-- Spec 3: X, Y, and Z MUST NOT contain leading zeroes
test('No leading zeros - invalid cases', function()
	assert_nil(semver.try_parse('01.0.0'), 'Major with leading zero should be invalid')
	assert_nil(semver.try_parse('1.01.0'), 'Minor with leading zero should be invalid')
	assert_nil(semver.try_parse('1.0.01'), 'Patch with leading zero should be invalid')
	assert_nil(semver.try_parse('01.01.01'), 'All with leading zeros should be invalid')
end)

test('No leading zeros - valid single zero', function()
	local version = semver.parse('0.0.0')
	assert_equal(version.major, 0)
	assert_equal(version.minor, 0)
	assert_equal(version.patch, 0)
end)

-- Spec 4: Each element MUST increase numerically
test('Numeric ordering', function()
	assert_equal(semver.is_latest(semver.parse('2.0.0'), semver.parse('1.0.0')), true)
	assert_equal(semver.is_latest(semver.parse('1.2.0'), semver.parse('1.1.0')), true)
	assert_equal(semver.is_latest(semver.parse('1.0.2'), semver.parse('1.0.1')), true)
end)

-- Spec 5: Pre-release version MAY be denoted by appending a hyphen
test('Pre-release with hyphen', function()
	local version = semver.parse('1.0.0-alpha')
	assert_equal(version.major, 1)
	assert_equal(version.minor, 0)
	assert_equal(version.patch, 0)
	assert_not_nil(version.pre_release)
	assert_table_equal(version.pre_release :: { string }, { 'alpha' })
end)

-- Spec 6: Pre-release identifiers MUST comprise only ASCII alphanumerics and hyphens
test('Pre-release alphanumeric and hyphens', function()
	local version1 = semver.parse('1.0.0-alpha-beta')
	assert_table_equal(version1.pre_release :: { string }, { 'alpha-beta' })

	local version2 = semver.parse('1.0.0-alpha.beta.1')
	assert_table_equal(version2.pre_release :: { string }, { 'alpha', 'beta', '1' })

	local version3 = semver.parse('1.0.0-0.3.7')
	assert_table_equal(version3.pre_release :: { string }, { '0', '3', '7' })

	local version4 = semver.parse('1.0.0-x.7.z.92')
	assert_table_equal(version4.pre_release :: { string }, { 'x', '7', 'z', '92' })
end)

-- Spec 7: Pre-release identifiers MUST NOT be empty
test('Pre-release not empty', function()
	assert_nil(semver.try_parse('1.0.0-'), 'Empty pre-release should be invalid')
	assert_nil(semver.try_parse('1.0.0-.alpha'), 'Empty pre-release identifier should be invalid')
	assert_nil(semver.try_parse('1.0.0-alpha.'), 'Empty pre-release identifier should be invalid')
	assert_nil(semver.try_parse('1.0.0-alpha..beta'), 'Empty pre-release identifier should be invalid')
end)

-- Spec 8: Numeric identifiers MUST NOT include leading zeroes
test('Pre-release numeric no leading zeros', function()
	local version1 = semver.parse('1.0.0-1')
	assert_table_equal(version1.pre_release :: { string }, { '1' })

	local version2 = semver.parse('1.0.0-0')
	assert_table_equal(version2.pre_release :: { string }, { '0' })

	-- Note: The spec is unclear about leading zeros in alphanumeric identifiers
	-- Most implementations allow them for non-purely-numeric identifiers
	local version3 = semver.parse('1.0.0-01alpha')
	assert_table_equal(version3.pre_release :: { string }, { '01alpha' })
end)

-- Spec 9: Pre-release has lower precedence than normal version
test('Pre-release precedence', function()
	assert_equal(semver.is_latest(semver.parse('1.0.0'), semver.parse('1.0.0-alpha')), true)
	assert_equal(semver.is_oldest(semver.parse('1.0.0-alpha'), semver.parse('1.0.0')), true)
end)

-- Spec 10: Precedence for pre-release versions with same major.minor.patch
test('Pre-release comparison', function()
	local versions = {
		semver.parse('1.0.0-alpha'),
		semver.parse('1.0.0-alpha.1'),
		semver.parse('1.0.0-alpha.beta'),
		semver.parse('1.0.0-beta'),
		semver.parse('1.0.0-beta.2'),
		semver.parse('1.0.0-beta.11'),
		semver.parse('1.0.0-rc.1'),
		semver.parse('1.0.0'),
	}

	table.sort(versions, semver.is_oldest)

	local expected_order = {
		'1.0.0-alpha',
		'1.0.0-alpha.1',
		'1.0.0-alpha.beta',
		'1.0.0-beta',
		'1.0.0-beta.2',
		'1.0.0-beta.11',
		'1.0.0-rc.1',
		'1.0.0',
	}

	for i, version in versions do
		assert_equal(semver.tostring(version), expected_order[i], `Version order mismatch at position {i}`)
	end
end)

-- Spec 11: Build metadata MAY be denoted by appending a plus sign
test('Build metadata with plus', function()
	local version = semver.parse('1.0.0+20130313144700')
	assert_equal(version.major, 1)
	assert_equal(version.minor, 0)
	assert_equal(version.patch, 0)
	assert_nil(version.pre_release)
	assert_not_nil(version.build_metadata)
	assert_table_equal(version.build_metadata :: { string }, { '20130313144700' })
end)

test('Build metadata with pre-release', function()
	local version = semver.parse('1.0.0-beta+exp.sha.5114f85')
	assert_table_equal(version.pre_release :: { string }, { 'beta' })
	assert_table_equal(version.build_metadata :: { string }, { 'exp', 'sha', '5114f85' })
end)

-- Spec 12: Build metadata identifiers MUST comprise only ASCII alphanumerics and hyphens
test('Build metadata alphanumerics and hyphens', function()
	local version1 = semver.parse('1.0.0+build.1')
	assert_table_equal(version1.build_metadata :: { string }, { 'build', '1' })

	local version2 = semver.parse('1.0.0+build-1')
	assert_table_equal(version2.build_metadata :: { string }, { 'build-1' })

	-- Test invalid characters should fail
	assert_nil(semver.try_parse('1.0.0+build_1'), 'Underscore should be invalid in build metadata')
	assert_nil(semver.try_parse('1.0.0+build@1'), '@ should be invalid in build metadata')
end)

-- Spec 13: Build metadata identifiers MUST NOT be empty
test('Build metadata not empty', function()
	assert_nil(semver.try_parse('1.0.0+'), 'Empty build metadata should be invalid')
	assert_nil(semver.try_parse('1.0.0+.build'), 'Empty build metadata identifier should be invalid')
	assert_nil(semver.try_parse('1.0.0+build.'), 'Empty build metadata identifier should be invalid')
	assert_nil(semver.try_parse('1.0.0+build..1'), 'Empty build metadata identifier should be invalid')
end)

-- Spec 14: Build metadata SHOULD be ignored when determining version precedence
test('Build metadata ignored in precedence', function()
	local version1 = semver.parse('1.0.0+build1')
	local version2 = semver.parse('1.0.0+build2')
	local version3 = semver.parse('1.0.0')

	-- These should be considered equal in precedence
	assert_equal(semver.is_latest(version1, version2), false, '1.0.0+build1 should not be > 1.0.0+build2')
	assert_equal(semver.is_latest(version2, version1), false, '1.0.0+build2 should not be > 1.0.0+build1')
	assert_equal(semver.is_latest(version1, version3), false, '1.0.0+build1 should not be > 1.0.0')
	assert_equal(semver.is_latest(version3, version1), false, '1.0.0 should not be > 1.0.0+build1')

	-- Since they're equal, is_oldest should return true (not is_latest)
	assert_equal(semver.is_oldest(version1, version2), true)
	assert_equal(semver.is_oldest(version2, version1), true)
end)

-- Additional edge cases and complex scenarios
test('Complex version string', function()
	local version = semver.parse('1.2.3-alpha.beta.3.cavalo+build.sha.349F8D04AB')
	assert_equal(version.major, 1)
	assert_equal(version.minor, 2)
	assert_equal(version.patch, 3)
	assert_table_equal(version.pre_release :: { string }, { 'alpha', 'beta', '3', 'cavalo' })
	assert_table_equal(version.build_metadata :: { string }, { 'build', 'sha', '349F8D04AB' })
end)

test('Optional v prefix', function()
	local version1 = semver.parse('v1.2.3')
	local version2 = semver.parse('1.2.3')

	assert_equal(version1.major, version2.major)
	assert_equal(version1.minor, version2.minor)
	assert_equal(version1.patch, version2.patch)
end)

test('String representation', function()
	assert_equal(semver.tostring(semver.parse('1.2.3')), '1.2.3')
	assert_equal(semver.tostring(semver.parse('1.2.3-alpha')), '1.2.3-alpha')
	assert_equal(semver.tostring(semver.parse('1.2.3+build')), '1.2.3+build')
	assert_equal(semver.tostring(semver.parse('1.2.3-alpha+build')), '1.2.3-alpha+build')
end)

test('is_valid function', function()
	assert_not_nil(semver.is_valid('1.2.3'))
	assert_not_nil(semver.is_valid('1.2.3-alpha'))
	assert_not_nil(semver.is_valid('1.2.3+build'))
	assert_nil(semver.is_valid('invalid'))
	assert_nil(semver.is_valid('01.2.3'))
end)

-- Invalid cases that should fail
test('Invalid version formats', function()
	local invalid_versions = {
		'',
		'1',
		'1.2',
		'1.2.3.4',
		'a.b.c',
		'1.2.3-',
		'1.2.3+',
		'1.2.3-α', -- Non-ASCII character
		'1.2.3+α', -- Non-ASCII character
		'1.2.3-alpha.',
		'1.2.3+build.',
		'1.2.3-alpha..beta',
		'1.2.3+build..1',
		'01.0.0',
		'1.01.0',
		'1.0.01',
		'1.2.3-alpha_beta', -- Underscore in pre-release
		'1.2.3+build_1', -- Underscore in build
	}

	for _, invalid in invalid_versions do
		assert_nil(semver.try_parse(invalid), `"{invalid}" should be invalid`)
	end
end)

-- Original functionality test
test('Original functionality test', function()
	print(semver.parse('1.2.3-alpha.beta.3.cavalo+build.sha.349F8D04AB'))

	local vers = {
		semver.parse '1.0.0-alpha',
		semver.parse '1.0.0-alpha.1',
		semver.parse '1.0.0-alpha.beta',
		semver.parse '1.0.0-beta',
		semver.parse '1.0.0-beta.2',
		semver.parse '1.0.0-beta.11',
		semver.parse '1.0.0-rc.1',
		semver.parse '1.0.0',
		semver.parse '1.0.1',
		semver.parse '2.0.0',
	}

	table.sort(vers, semver.is_oldest)

	local raws = {}
	for i, ver in vers do
		raws[i] = semver.tostring(ver)
	end

	local expected =
		'1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0 < 1.0.1 < 2.0.0'
	local actual = table.concat(raws, ' < ')

	assert_equal(actual, expected, 'Original functionality test failed')
end)

-- Run all tests and show summary
print(`\n🏁 Test Summary: {passed_count}/{test_count} passed`)
if passed_count == test_count then
	print('🎉 All tests passed!')
	return true
else
	print('💥 Some tests failed!')
	return false
end
