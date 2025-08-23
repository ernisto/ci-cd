# Semantic Versioning Parser

A semantic versioning parser implemented in pure Luau, following 100% of the official [Semantic Versioning 2.0.0](https://semver.org/) specifications.

## Features

- ✅ **Pure Luau** - No external dependencies
- ✅ **100% compliant** with semver.org specification
- ✅ **Comprehensive tests** - 21 tests covering all aspects of the spec
- ✅ **Hybrid parsing** - Native regex + manual parsing for maximum precision
- ✅ **Strict validation** - Rejects invalid formats according to specification

## Usage

```luau
local semver = require('./lib')

-- Basic parsing
local version = semver.parse("1.2.3")
print(version.major, version.minor, version.patch) -- 1, 2, 3

-- With pre-release and build metadata
local complex = semver.parse("1.2.3-alpha.beta.1+build.sha.123")
print(complex.pre_release)    -- {"alpha", "beta", "1"}
print(complex.build_metadata) -- {"build", "sha", "123"}

-- Version comparison
local v1 = semver.parse("1.0.0")
local v2 = semver.parse("1.0.0-alpha")
print(semver.is_latest(v1, v2)) -- true (normal > pre-release)

-- Sorting
local versions = {
    semver.parse("1.0.0-alpha"),
    semver.parse("1.0.0-beta"),
    semver.parse("1.0.0")
}
table.sort(versions, semver.is_oldest)
```

## API

### `semver.parse(input: string): version`
Parses a version string. Throws an error if invalid.

### `semver.try_parse(input: string): version?` 
Parses a version string. Returns `nil` if invalid.

### `semver.is_valid(input: string): string?`
Checks if a string is a valid version. Returns the string if valid, `nil` otherwise.

### `semver.is_latest(v1: version, v2: version): boolean`
Returns `true` if `v1` is later than `v2`.

### `semver.is_oldest(v1: version, v2: version): boolean`
Returns `true` if `v1` is earlier than `v2`.

### `semver.tostring(version: version): string`
Converts a version back to string.

### `semver.new_from(base: version, patch: partial_version): version`
Creates a new version based on another, applying partial changes.

## Types

```luau
type version = {
    major: number,
    minor: number,
    patch: number,
    pre_release: {string}?,      -- nil if not present
    build_metadata: {string}?,   -- nil if not present
}

type partial_version = {
    major: number?,
    minor: number?,
    patch: number?,
    pre_release: {string}?,
    build_metadata: {string}?,
}
```

## Implemented Specifications

### ✅ Basic Format
- **Spec 1**: Format `X.Y.Z` where X, Y, Z are non-negative integers
- **Spec 2**: X, Y, Z are non-negative integers  
- **Spec 3**: X, Y, Z MUST NOT contain leading zeroes (except "0")
- **Spec 4**: Each element MUST increase numerically

### ✅ Pre-release
- **Spec 5**: Pre-release MAY be denoted by appending a hyphen (`-`)
- **Spec 6**: Identifiers MUST comprise only ASCII alphanumerics and hyphens
- **Spec 7**: Identifiers MUST NOT be empty
- **Spec 8**: Numeric identifiers MUST NOT include leading zeroes
- **Spec 9**: Pre-release has lower precedence than normal version
- **Spec 10**: Precedence for pre-release follows specific rules

### ✅ Build Metadata
- **Spec 11**: Build metadata MAY be denoted by appending a plus (`+`)
- **Spec 12**: Identifiers MUST comprise only ASCII alphanumerics and hyphens
- **Spec 13**: Identifiers MUST NOT be empty
- **Spec 14**: Build metadata SHOULD be ignored when determining version precedence

## Running Tests

```bash
# Complete tests
lune run test.luau

# Original functionality test
lune run lib.spec.luau
```

## Examples of Valid Versions

```
1.0.0
1.0.0-alpha
1.0.0-alpha.1
1.0.0-alpha.beta
1.0.0-beta
1.0.0-beta.2
1.0.0-beta.11
1.0.0-rc.1
1.0.0+20130313144700
1.0.0-beta+exp.sha.5114f85
1.2.3-alpha.beta.3.cavalo+build.sha.349F8D04AB
```

## Examples of Invalid Versions

```
01.0.0          # Leading zero in major
1.01.0          # Leading zero in minor  
1.0.01          # Leading zero in patch
1.2.3-          # Empty pre-release
1.2.3+          # Empty build metadata
1.2.3-alpha.    # Empty identifier
1.2.3+build.    # Empty identifier
1.2.3-α         # Non-ASCII character
1.2.3+build_1   # Underscore not allowed
1.2.3.4         # Incorrect format
```

## Implementation

The parser uses a hybrid approach:

1. **Native Luau regex** for parsing the basic `MAJOR.MINOR.PATCH` structure
2. **Manual parsing** for strict validation of pre-release and build metadata
3. **Character validation** using Luau patterns
4. **Precedence comparison** following the specification exactly

This approach ensures maximum compatibility with the specification while maintaining performance and requiring no external dependencies.
