--!strict

type _Component = { [any]: any }

export type Effect<C, I> = typeof(setmetatable(
	{} :: {
		_getComponentData: () -> _Component,

		offset: (by: CFrame) -> Effect<C, I>,
		parent: (to: Instance) -> Effect<C, I>,

		destroy: () -> Effect<C, I>,
		destroyAfter: (duration: number) -> Effect<C, I>,
	},
	{} :: {
		__index: Effect<C, I>,
		__call: C,
	}
))

local DEFAULT = table.freeze {
	origin = CFrame.identity,
	parent = workspace,
} :: {
	origin: CFrame,
	parent: Instance | Workspace,
}

local function component(data): _Component
	local _component = {}
	do
		function _component:patch(partialNewData)
			local newData = table.clone(data)
			for index, value in partialNewData do
				newData[index] = value
			end

			return component(table.freeze(newData))
		end

		function _component:get()
			return data
		end
	end

	return table.freeze(_component)
end

local Effect = {
	util = require(script.util),
}

function Effect.serialize(instance)
	local serialize = {}
	function serialize.from(effect)
		local data = effect._getComponentData()

		local item = instance:Clone()
		item.Parent = data.parent

		do
			table.insert(effect._collection, item)

			local root = Effect.util.getRootPart(item)
			if root then
				root.CFrame = data.origin
			end
		end

		return item
	end

	return serialize
end

function Effect.new(): Effect<(self: Effect<any, any>, instance: Instance) -> Instance, any> & () -> any
	local data = component(DEFAULT)

	local effect = setmetatable({}, {})
	effect.__index = effect

	function effect:__call(instance: Instance)
		return Effect.serialize(instance).from(effect)
	end

	do
		effect._collection = {} :: { [any]: Instance }

		function effect._getComponentData()
			return data:get()
		end

		function effect.offset(by)
			data = data:patch {
				origin = data:get().origin * by,
			}

			return effect
		end

		function effect.parent(to)
			local root = Effect.util.getRootPart(to)
			local origin = if root then root.CFrame else CFrame.identity

			data = data:patch {
				parent = to,
				origin = origin,
			}

			return effect
		end

		function effect.destroy()
			for _, item in effect._collection do
				item:Destroy()
			end

			return effect
		end

		function effect.destroyAfter(duration)
			task.delay(duration, effect.destroy)

			return effect
		end
	end

	return effect :: any
end

function Effect.from(
	instance: Instance
): Effect<(self: Effect<any, any>, instance: Instance) -> Instance, any> & () -> Instance
	local prefab = Effect.new()

	local metadata = getmetatable(prefab)
	function metadata:__call()
		return Effect.serialize(instance).from(prefab)
	end

	return prefab
end

return table.freeze(Effect)
