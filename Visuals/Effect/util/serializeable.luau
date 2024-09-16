--!strict

local BasePart = {
	'CFrame',
	'Size',
	'Color',
}

return {
	Part = BasePart,
	MeshPart = BasePart,

	SpecialMesh = {
		'Scale',
		'Offset',
	},

	Beam = {
		'Brightness',

		'LightEmission',
		'LightInfluence',

		'ZOffset',

		'TextureSpeed',
		'TextureLength',

		'CurveSize0',
		'CurveSize1',

		'Width0',
		'Width1',
	},

	Weld = {
		'C0',
		'C1',
	},

	Attachment = {
		'CFrame',
	},

	PointLight = {
		'Brightness',
		'Range',
	},

	Highlight = {
		'FillTransparency',
		'OutlineTransparency',
		'FillColor',
		'OutlineColor',
	},

	Decal = {
		'Color3',
		'Transparency',
		'ZIndex',
	},
}
