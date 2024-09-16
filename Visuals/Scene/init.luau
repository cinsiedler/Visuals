--!strict

local Collection = require(script.Collection)

local createReconciler = require(script.createReconciler)

local Component = {}

function Component:construct(name)
	local componentReconciler = createReconciler()
	Collection.insert(componentReconciler).as(name)
end

function Component:call(name, ...)
	Collection.get(name):play(...)
end

return Component
