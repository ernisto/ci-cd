local types = require('@lib/types')
local index = require('@self/index')

export type user = types.user
export type sha1 = types.sha1
export type entry = index.entry
export type index = index.index

export type ref_id = types.ref_id
export type ref = types.ref
export type tag = types.tag
export type head = types.head
export type remote = types.remote

export type tree_child = types.tree_child
export type object = types.object
export type commit = types.commit
export type tree = types.tree
export type blob = types.blob

-- module
return table.freeze({
	object = require('@self/object'),
	commit = require('@self/object/commit'),
	tree = require('@self/object/tree'),
	blob = require('@self/object/blob'),

	ref = require('@self/ref'),
	remote = require('@self/ref/remote'),
	head = require('@self/ref/head'),
	tag = require('@self/ref/tag'),

	index = require('@self/index'),
	query = require('@self/query'),
	user = require('@self/user'),
	mock = require('@self/mock'),
})
