local windSpeedMultiplier = 22

local turbineNames = {
	["ownly_wind_turbine_build_mk1"] = 1,
	["ownly_wind_turbine_build_mk2"] = 2,
	["ownly_wind_turbine_build_mk3"] = 3,
	["ownly_wind_turbine_mk1"] = 1,
	["ownly_wind_turbine_mk2"] = 2,
	["ownly_wind_turbine_mk3"] = 3,
}

local basePower = settings.global["ownly_windturbines_base_power"].value

local function onInit()
	global.turbines = {}
end

local function onConfigurationChanged()
	if settings.global["ownly_windturbines_base_power"].value ~= basePower then
		basePower = settings.global["ownly_windturbines_base_power"].value
		
		for _, turbine in pairs(global.turbines) do
			if turbine.base and turbine.base.valid then
				turbine.base.electric_buffer_size = (2 ^ (turbine.level - 1) * basePower*1000)/60
			end
		end
	end
	
	-- If the setting for locked power is set we need to set each placed turbine to a fixed power output
	if settings.global["ownly_windturbines_locked_power"].value then
		for _, turbine in pairs(global.turbines) do
			if turbine.base and turbine.base.valid then
				turbine.base.power_production = basePower*1000 / 60 * 2 ^ (turbine.level - 1)
			end
		end
	end
end

local function validateTurbine(unit_number)
	local turbine = global.turbines[unit_number]
	
	if not turbine
		or not turbine.base
		or not turbine.base.valid
		or not turbine.collision_box
		or not turbine.collision_box.valid
	then
		return false
	end
	
	return true
end

local function destroyTurbine(unit_number, died)
	if not global.turbines[unit_number] then
		return
	end
	
	if died then
		if global.turbines[unit_number].base and global.turbines[unit_number].base.valid then
			SCRIPT_KILL = true
			global.turbines[unit_number].base.die(global.turbines[unit_number].base.force)
			SCRIPT_KILL = nil
		end
	elseif global.turbines[unit_number].base then
		global.turbines[unit_number].base.destroy()
	end
	
	rendering.destroy(global.turbines[unit_number].turbine)
	rendering.destroy(global.turbines[unit_number].shadow)
	
	if global.turbines[unit_number].collision_box then
		global.turbines[unit_number].collision_box.destroy()
	end
	
	global.turbines[unit_number] = nil
end

local function eventEntityDied(event)
	if SCRIPT_KILL then
		return
	end
	
	if not turbineNames[event.entity.name] or not global.turbines[event.entity.unit_number] then
		return
	end

	destroyTurbine(event.entity.unit_number, true)
end

local function varyWindSpeed(event)
	if game.active_mods["WindSpeedChanging-Tweaked"] or game.active_mods["WindSpeedChanging"] or settings.global["ownly_windturbines_vary_windspeed"].value == false then
		return
	end
	
	for _, surface in pairs(game.surfaces) do
		-- Vary the wind speed and make sure it's never below 0.001.
		-- Substract 0.002 from wind_speed and add 0.4% of a math.random() value to it.
		-- Take 97.5% of this and add 0.00052.
		surface.wind_speed = math.max(0.001, (surface.wind_speed - 0.002 + math.random() * 0.004) * 0.975 + 0.00052)
	end
end

local function updateTurbines (event)
	local wind_orientations = {}
	local wind_speeds = {}
	
	for surface_name, surface in pairs(game.surfaces) do
		wind_orientations[surface_name] = math.floor(surface.wind_orientation * 32 + 0.499)
		if wind_orientations[surface_name] > 31 then
			wind_orientations[surface_name] = 0
		end
		wind_orientations[surface_name] = (wind_orientations[surface_name] + 16) % 31
		wind_speeds[surface_name] = surface.wind_speed
	end
	
	-- run at max once and increase the number of updates with every turbine built
	-- 1: 1/20 + global.fractional_tick => 0.05 + 0; 0.05 + 0.05; 0.1 + 0.05; ...
	-- 6: 6/20 + global.fractional_tick => 0.3 + 0; 0.3 + 0.3; 0.6 + 0.9;
	-- 20: 20/20 + global.fractional_tick => 1 + 0; 1 + 1; 1 + 1
	local runs = math.min(1, table_size(global.turbines) / 20 + (global.fractional_tick or 0))
	global.fractional_tick = runs % 1
	
	for i = 1, runs do
		local remove_entry
		
		if global.iterate and not global.turbines[global.iterate] then
			global.iterate = nil
		end
		
		if global.iterate then
			if not validateTurbine(global.iterate) then
				-- We should remove this turbine as it is not valid
				remove_entry = global.iterate
			else
				-- The turbine is valid so the animation and power generation should be updated
				local turbine = global.turbines[global.iterate]
				
				-- If the wind direction has changed we should update the turbine heading
				if turbine.orientation ~= wind_orientations[turbine.surface] then
					local level = turbine.level
					local orientation = wind_orientations[turbine.surface]
					
					rendering.set_animation(turbine.turbine, "ownly_wind_turbine_mk" .. level .. "_" .. orientation)
					rendering.set_animation(turbine.shadow, "ownly_wind_turbine_shadow_" .. orientation)
					
					turbine.orientation = orientation
				end
				
				local current_wind_speed = wind_speeds[turbine.base.surface.name] * windSpeedMultiplier
				
				-- If the wind speed has changed we should update the animation speed and power generation
				if turbine.last_speed ~= current_wind_speed then
					local expected_frame = (((game.tick * turbine.last_speed) + turbine.last_offset) % 24)
					local new_frame = (((game.tick * current_wind_speed)) % 24)
					local new_offset = (expected_frame - new_frame) % 24
					
					-- game.print("currently at frame: "..expected_frame)
					-- game.print("new frame w/o offset: "..new_frame)
					-- game.print("new offset: "..new_offset)
					
					rendering.set_animation_speed(turbine.turbine, current_wind_speed)
					rendering.set_animation_speed(turbine.shadow, current_wind_speed)
					rendering.set_animation_offset(turbine.shadow, new_offset)
					rendering.set_animation_offset(turbine.turbine, new_offset)
					
					turbine.last_offset = new_offset
					turbine.last_speed = current_wind_speed
					
					-- If we're not in locked power mode update the generated power
					if not settings.global["ownly_windturbines_locked_power"].value then
						turbine.base.power_production = basePower*1000 / 60 * 2 ^ (turbine.level - 1) * (current_wind_speed / 0.457)
					end
				end
			end
		end
		
		-- Update iterator
		global.iterate = next(global.turbines, global.iterate)
		
		-- Start from the fornt
		if not global.iterate then
			global.iterate = next(global.turbines, global.iterate)
		end
		
		-- If it's an invalid turbine remove it
		if remove_entry then
			destroyTurbine(remove_entry, true)
		end
	end
end

local function entityBuilt(event)
	local entity = event.created_entity or event.entity
	
	if not turbineNames[entity.name] then
		return
	end
	
	local orientation = 16
	local position = entity.position
	local force = entity.force
	local surface = entity.surface
	local level = turbineNames[entity.name]
	entity.destroy()
	
	local new_entity = surface.create_entity {
			name = "ownly_wind_turbine_mk" .. level,
			position = position,
			force = force
		}
	
	local collision_box = surface.create_entity {
			name = "ownly_wind_turbine_collision_box_mk" .. level,
			position = { position.x + 0, position.y - 0 }, force = force
		}
	
	collision_box.destructible = false
	collision_box.minable = false
	
	new_entity.electric_buffer_size = (2 ^ (level - 1) * basePower*1000)/60
	new_entity.power_production = basePower*1000 / 60 * 2 ^ (level - 1)
	
	global.turbines[new_entity.unit_number] = {
		base = new_entity,
		collision_box = collision_box,
		surface = surface.name,
		orientation = 16,
		level = level,
		turbine = rendering.draw_animation {
			animation = "ownly_wind_turbine_mk" .. level .. "_" .. orientation,
			target = { position.x, position.y - 10 },
			surface = surface, animation_speed = surface.wind_speed * windSpeedMultiplier,
			render_layer = "wires-above"
		},
		shadow = rendering.draw_animation {
			animation = "ownly_wind_turbine_shadow_" .. orientation,
			target = { position.x + 6, position.y - 1 },
			surface = surface,
			animation_speed = surface.wind_speed * windSpeedMultiplier
		},
		last_change = game.tick,
		last_speed = surface.wind_speed * windSpeedMultiplier,
		creation_tick = game.tick,
		last_frame_count = 0,
		last_offset = 0,
	}
end

local function entityRemoved(event)
	local entity = event.entity
	
	if not turbineNames[entity.name] or not global.turbines[entity.unit_number] then
		return
	end
	
	destroyTurbine(entity.unit_number)
end

script.on_init(onInit)
script.on_configuration_changed(onConfigurationChanged)

script.on_event(defines.events.on_built_entity, entityBuilt)
script.on_event(defines.events.on_robot_built_entity, entityBuilt)
script.on_event(defines.events.script_raised_revive, entityBuilt)

script.on_event(defines.events.on_player_mined_entity, entityRemoved)
script.on_event(defines.events.on_entity_died, entityRemoved)
script.on_event(defines.events.on_robot_mined_entity, entityRemoved)

script.on_event(defines.events.on_entity_died, eventEntityDied)

script.on_event(defines.events.on_runtime_mod_setting_changed, onConfigurationChanged)

-- every every 5 seconds vary wind speed on each surface
script.on_nth_tick(300, varyWindSpeed)

-- Every 2/60 of a second update the animation and power generation.
script.on_nth_tick(2, updateTurbines)