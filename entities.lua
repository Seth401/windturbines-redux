COLLISION_BOX = {{-1.2, -1.2}, {1.2, 1.2}}
SHADOW_OFFSET = {9.5,-3.6}
MAIN_OFFSET = {0.15, -11}
BLADES_OFFSET = {0.15, -1}
BLADES_SHADOW_OFFSET = {9.5,2.4}
BLADES_SHADOW_OFFSET = {3.5,-2.6}



for i=0,31 do
	local rota = i
	if settings.startup["ownly_windturbines_low_vram"].value then
		rota = math.floor(i/2)*2
	end
	data:extend({
		{
			type = "animation",
			name = "ownly_wind_turbine_shadow_"..i,
			
			filename = "__windturbines-redux__/graphics/LD/shadows/"..math.floor(rota)..".png",
			width = 400,
			height = 200,
			frame_count = 24,
			line_length = 5,
			shift = BLADES_SHADOW_OFFSET,
			animation_speed = 1,
			draw_as_shadow = true,
			scale = 4,
			hr_version =
			{
				filename = "__windturbines-redux__/graphics/HD/shadows/"..math.floor(rota)..".png",
				width = 800,
				height = 400,
				frame_count = 24,
				line_length = 5,
				shift = BLADES_SHADOW_OFFSET,
				scale = 2,
				animation_speed = 1,
				draw_as_shadow = true,
			}
		}
	})
end

for level=1,3 do
	data:extend({
		{
			type = "simple-entity-with-force",
			name = "ownly_wind_turbine_collision_box_mk"..level,
			icon = "__base__/graphics/icons/steel-chest.png",
			icon_size = 32,
			flags = {"placeable-neutral", "player-creation", "not-on-map"},
			order = "s-e-w-f",
			max_health = 500,
			corpse = "small-remnants",
			collision_box = {{-16.5, -16.5}, {16.5, 16.5}},
			collision_mask = {"resource-layer"},
			selection_box = {{-0.9, -0.9}, {0.9, 0.9}},
			selectable_in_game = false,
			render_layer = "wires-above",
			random_animation_offset = false,
			picture = {
					filename = "__windturbines-redux__/graphics/transparent32.png",
					width = 32,
					height = 32,
					
				},
		}
	})
	for i=0,31 do
		local rota = i
		if settings.startup["ownly_windturbines_low_vram"].value then
			rota = math.floor(i/2)*2
		end

		data:extend({
			{
				type = "animation",
				name = "ownly_wind_turbine_mk"..level.."_"..i,
				filename = "__windturbines-redux__/graphics/LD/mk"..level.."/"..math.floor(rota)..".png",
				width = 300,
				height = 400,
				frame_count = 24,
				line_length = 6,
				shift = BLADES_OFFSET,
				animation_speed = 1,
				scale = 2,
				hr_version = {
					filename = "__windturbines-redux__/graphics/HD/mk"..level.."/"..math.floor(rota)..".png",
					width = 600,
					height = 800,
					frame_count = 24,
					line_length = 6,
					shift = BLADES_OFFSET,
					animation_speed = 1,
				}
			},
		})
	end
	data:extend({
		{
			type = "electric-energy-interface",
			name = "ownly_wind_turbine_build_mk"..level,
			icon = "__windturbines-redux__/graphics/mk"..level.."_icon.png",
			icon_size = 144,
			order = "a",
			flags = {"placeable-neutral","player-creation"},
			minable = {mining_time = 0.5, result = "ownly_wind_turbine_mk"..level},
			max_health = 500,
			corpse = "medium-remnants",
			effectivity = 1,
			resistances = {
				{
					type = "physical",
					percent = 10
				}
			},
			collision_box = COLLISION_BOX,
			selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
			collision_mask = {"resource-layer","object-layer", "player-layer", "water-tile"},
			energy_source = {
				type = "electric",
				usage_priority = "primary-output",
				input_flow_limit = "0kW",
				output_flow_limit = 2^(level-1)*750 .."kW",
				buffer_capacity = 2^(level-1)*750 .."kJ",
				render_no_power_icon = false
			},
			energy_production = 2^(level-1)*750 .."kW",
			energy_usage = "0kW",
			animations = {layers = {
				{
					filename = "__windturbines-redux__/graphics/LD/mk"..level.."/build_dummy.png",
					width = 300,
					height = 400,
					frame_count = 24,
					line_length = 6,
					shift = MAIN_OFFSET,
					animation_speed = 0.4,
					scale = 2,
					hr_version = {
						filename = "__windturbines-redux__/graphics/HD/mk"..level.."/build_dummy.png",
						width = 600,
						height = 800,
						frame_count = 24,
						line_length = 6,
						shift = MAIN_OFFSET,
						animation_speed = 0.4,
						--scale = 2,
					}
				},
				{
					filename = "__windturbines-redux__/graphics/LD/shadows/16.png",
					width = 400,
					height = 200,
					frame_count = 24,
					line_length = 5,
					shift = SHADOW_OFFSET,
					animation_speed = 0.4,
					draw_as_shadow = true,
					scale = 4,
					hr_version = {
						filename = "__windturbines-redux__/graphics/HD/shadows/16.png",
						width = 800,
						height = 400,
						frame_count = 24,
						line_length = 5,
						scale = 2,
						shift = SHADOW_OFFSET,
						animation_speed = 0.4,
						draw_as_shadow = true,
						--scale = 2,
					}
				}
			}},
			
			random_animation_offset = false,
			working_sound = {
				sound = {
					filename = "__base__/sound/train-wheels.ogg",
					volume = 0.6
				},
				match_speed_to_activity = true,
			},
			min_perceived_performance = 0.25,
		},
		{
			type = "electric-energy-interface",
			name = "ownly_wind_turbine_mk"..level,
			icon = "__windturbines-redux__/graphics/mk"..level.."_icon.png",
			icon_size = 144,
			order = "a",
			flags = {"placeable-neutral","player-creation"},
			minable = {mining_time = 0.5, result = "ownly_wind_turbine_mk"..level},
			placeable_by = {item = "ownly_wind_turbine_mk"..level, count = 1},
			max_health = 500,
			corpse = "big-remnants",
			effectivity = 1,
			resistances = {
				{
					type = "physical",
					percent = 10
				}
			},
			collision_box = COLLISION_BOX,
			selection_box = {{-0.9, -0.9}, {0.9, 0.9}},
			collision_mask = {"resource-layer","object-layer", "player-layer", "water-tile"},
			energy_source = {
				type = "electric",
				usage_priority = "primary-output",
				input_flow_limit = "0kW",
				output_flow_limit = 2^(level-1)*750*2 .."kW",
				buffer_capacity = 2^(level-1)*750 .."kJ",
				render_no_power_icon = false
			},
			energy_production = 2^(level-1)*750 .."kW",
			energy_usage = "0kW",
			picture = {
					filename = "__windturbines-redux__/graphics/LD/mk"..level.."/base.png",
					width = 300,
					height = 400,
					frame_count = 1,
					line_length = 1,
					shift = MAIN_OFFSET,
					animation_speed = 0.4,
					scale = 2,
					hr_version = {
						filename = "__windturbines-redux__/graphics/HD/mk"..level.."/base.png",
						width = 600,
						height = 800,
						frame_count = 1,
						line_length = 1,
						shift = MAIN_OFFSET,
						animation_speed = 0.4,
					}
				},
				
			random_animation_offset = false,
			working_sound = {
				sound = {
					filename = "__base__/sound/train-wheels.ogg",
					volume = 0.6
				},
				match_speed_to_activity = true,
			},
			min_perceived_performance = 0.25,			
		},
	})
end