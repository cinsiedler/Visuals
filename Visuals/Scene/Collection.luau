--!strict

local Collection = { _cache = {} }

function Collection.insert(scene)
	local cache = Collection._cache

	local index = #cache + 1
	do
		cache[index] = scene
	end

	local collected = {}
	function collected.as(name)
		cache[index] = nil
		cache[name] = scene
	end

	return collected
end

function Collection.get(index)
	local cache = Collection._cache
	return cache[index]
end

return Collection
