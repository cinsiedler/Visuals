--!strict

type Morph = typeof(setmetatable(
	{},
	{} :: {
		__index: Morph,

		goals: { any },

		play: (self: Morph, ...TweenInfo) -> Morph,
		ungroup: (self: Morph) -> Instance,
	}
)) & () -> Instance

export type Util = {
	getRootPart: (item: Instance) -> BasePart?,

	emit: (item: Instance) -> Instance,

	enable: (item: Instance) -> nil,
	disable: (item: Instance) -> nil,

	morph: (model: Model) -> Morph?,
}

local TweenService = game:FindService 'TweenService' :: TweenService

local Util = {} :: Util

local function forEachEffectIn(item, callback)
	for _, effect in item:GetDescendants() do
		if
			not effect:IsA 'ParticleEmitter'
			and not effect:IsA 'Beam'
			and not effect:IsA 'Trail'
			and not effect:IsA 'PointLight'
		then
			continue
		end

		callback(effect)
	end
end

function Util.getRootPart(item)
	if item:IsA 'BasePart' then
		return item
	elseif item:IsA 'Model' and item.PrimaryPart then
		return item.PrimaryPart
	end

	return
end

function Util.emit(item)
	for _, particleEmitter in item:GetDescendants() do
		if not particleEmitter:IsA 'ParticleEmitter' then
			continue
		end

		local count = particleEmitter:GetAttribute 'EmitCount' :: number?
		local delay = particleEmitter:GetAttribute 'EmitDelay' :: number?

		local emit = particleEmitter.Emit :: (self: ParticleEmitter, count: number?) -> nil
		if not delay then
			emit(particleEmitter, count)
		else
			task.delay(delay, emit, particleEmitter, count)
		end
	end

	return item
end

local serializeable = require(script.serializeable)
function Util.morph(model: Model)
	local root = model:FindFirstChild '0' :: BasePart
	if not root then
		return
	end

	local morph = setmetatable({ goals = {} }, {})
	morph.__index = morph

	local frames = {}
	do
		for _, child in model:GetChildren() do
			local index = tonumber(child.Name)
			frames[index] = child
		end
	end

	do
		local goals = morph.goals
		local function createItemGoals(container, item: Instance)
			local name = item.Name
			local className = item.ClassName

			local propertiesToTrack = serializeable[className]
			local childrenToTrack = item:GetChildren()

			container[name] = {
				properties = {},
				children = {},
			}

			local itemContainer = container[name]

			if propertiesToTrack then
				for _, property in propertiesToTrack do
					itemContainer.properties[property] = (item :: any)[property]
				end
			end

			for _, child in childrenToTrack do
				createItemGoals(itemContainer.children, child)
			end
		end

		local function iterateItemGoals(container, item, tweenInfo: TweenInfo)
			local properties = container.properties
			local children = container.children

			TweenService:Create(item, tweenInfo, properties):Play()

			for _, child in item:GetChildren() do
				local childContainer = children[child.Name]
				if not childContainer then
					continue
				end

				iterateItemGoals(childContainer, child, tweenInfo)
			end
		end

		for index = 1, #frames do
			local item = frames[index] :: Instance

			goals[index] = {}
			do
				createItemGoals(goals[index], item)
				item:Destroy()
			end
		end

		function morph:play(...)
			local frameTweenInfos = { ... }
			local function play()
				for frame, container in goals do
					for _, data in container do
						local tweenInfo = frameTweenInfos[frame] :: TweenInfo
						iterateItemGoals(data, root, tweenInfo)

						task.wait(tweenInfo.Time)
					end
				end

				return
			end

			coroutine.wrap(play)()

			return morph
		end
	end

	function morph:ungroup()
		root.Parent = model.Parent
		model.Parent = root
		do
			model.Destroying:Once(function()
				root:Destroy()
			end)
		end

		return root
	end

	return morph :: Morph
end

function Util.enable(item)
	forEachEffectIn(item, function(effect)
		effect.Enabled = true
	end)

	return
end

function Util.disable(item)
	forEachEffectIn(item, function(effect)
		effect.Enabled = false
	end)

	return
end

return Util
