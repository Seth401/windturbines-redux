require "entities"
local level = 1
data:extend({
	{
		type = "item",
		name = "ownly_wind_turbine_mk"..level,
		icon = "__windturbines-redux__/graphics/mk"..level.."_icon.png",
		icon_size = 144,
		group = "logistics",
		subgroup = "energy",
		order = "d[solar-panel]-a[wind-turbine]",
		place_result = "ownly_wind_turbine_build_mk"..level,
		stack_size = 20
	},
	{
		type = "recipe",
		name = "ownly_wind_turbine_mk"..level,
		energy_required = 30,
		enabled = "false",
		ingredients = {
			{"plastic-bar", 40},
			{"steel-plate", 50},
			{"copper-cable", 120},
			{"electronic-circuit", 25},
			
		},
		result = "ownly_wind_turbine_mk"..level
	},
	{
		type = "technology",
		name = "ownly_wind_turbine_mk"..level,
		icon = "__windturbines-redux__/graphics/mk"..level.."_icon.png",
		icon_size = 144,
		prerequisites = {"logistic-science-pack","plastics"},
		effects = {
			{
				type = "unlock-recipe",
				recipe = "ownly_wind_turbine_mk"..level
			}
		},
		unit = {
			count = 200,
			ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}},
			time = 30
		}
	}
})

level = 2
data:extend({
	{
		type = "item",
		name = "ownly_wind_turbine_mk"..level,
		icon = "__windturbines-redux__/graphics/mk"..level.."_icon.png",
		icon_size = 144,
		group = "logistics",
		subgroup = "energy",
		order = "d[solar-panel]-a[wind-turbine]",
		place_result = "ownly_wind_turbine_build_mk"..level,
		stack_size = 20
	},
	{
		type = "recipe",
		name = "ownly_wind_turbine_mk"..level,
		energy_required = 30,
		enabled = "false",
		ingredients = {
			{"ownly_wind_turbine_mk1", 3},
			{"electric-engine-unit", 10},
			{"advanced-circuit", 25},
		},
		result = "ownly_wind_turbine_mk"..level
	},
	{
		type = "technology",
		name = "ownly_wind_turbine_mk"..level,
		icon = "__windturbines-redux__/graphics/mk"..level.."_icon.png",
		icon_size = 144,
		prerequisites = {"ownly_wind_turbine_mk1", "electric-engine", "electric-energy-distribution-1"},
		effects = {
			{
				type = "unlock-recipe",
				recipe = "ownly_wind_turbine_mk"..level
			}
		},
		unit = {
			count = 350,
			ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}},
			time = 30
		}
	}
})

level = 3
data:extend({
	{
		type = "item",
		name = "ownly_wind_turbine_mk"..level,
		icon = "__windturbines-redux__/graphics/mk"..level.."_icon.png",
		icon_size = 144,
		group = "logistics",
		subgroup = "energy",
		order = "d[solar-panel]-a[wind-turbine]",
		place_result = "ownly_wind_turbine_build_mk"..level,
		stack_size = 20
	},
	{
		type = "recipe",
		name = "ownly_wind_turbine_mk"..level,
		energy_required = 30,
		enabled = "false",
		ingredients = {
			{"ownly_wind_turbine_mk2", 3},
			{"low-density-structure", 50},
			{"processing-unit", 25},
		},
		result = "ownly_wind_turbine_mk"..level
	},
	{
		type = "technology",
		name = "ownly_wind_turbine_mk"..level,
		icon = "__windturbines-redux__/graphics/mk"..level.."_icon.png",
		icon_size = 144,
		prerequisites = {"ownly_wind_turbine_mk2", "low-density-structure","utility-science-pack"},
		effects = {
			{
				type = "unlock-recipe",
				recipe = "ownly_wind_turbine_mk"..level
			}
		},
		unit = {
			count = 500,
			ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"utility-science-pack", 1}},
			time = 30
		}
	}
})