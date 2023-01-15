WIND_SPEED_MULT = 22

turbine_names = {
	["ownly_wind_turbine_build_mk1"] = 1,
	["ownly_wind_turbine_build_mk2"] = 2,
	["ownly_wind_turbine_build_mk3"] = 3,
	["ownly_wind_turbine_mk1"] = 1,
	["ownly_wind_turbine_mk2"] = 2,
	["ownly_wind_turbine_mk3"] = 3,
}
script.on_init(function()
global.turbines = {}
global.version = 4

end)
script.on_configuration_changed(function()
	if not global.version then
		global.version = 1
		for a,b in pairs(global.turbines) do
			b.collision_box.destructible = false
			b.collision_box.minable = false
			b.shadow.destructible = false
			b.shadow.minable = false
		end
	end
	if global.version == 1 then
		for _, force in pairs(game.forces) do
			force.rechart()
		end
		global.version = 2
	end
	if global.version <3 then
		for a,b in pairs(global.turbines) do
			if b.base and b.base.valid then
				--game.print(b.turbine.name)
				b.turbine = rendering.draw_animation{animation =  "ownly_wind_turbine_mk"..b.level.."_"..b.orientation, target= {b.base.position.x,b.base.position.y-10}, surface = b.base.surface,animation_speed =b.base.surface.wind_speed*WIND_SPEED_MULT}
				b.shadow =  rendering.draw_animation{animation = "ownly_wind_turbine_shadow_"..b.orientation, target= {b.base.position.x+6,b.base.position.y-1}, surface = b.base.surface,animation_speed =b.base.surface.wind_speed*WIND_SPEED_MULT}
				b.last_change = game.tick
				b.last_speed = b.base.surface.wind_speed*WIND_SPEED_MULT
				b.creation_tick = game.tick
				b.last_frame_count = 0
				b.last_offset = 0
			end
		end
		global.version = 3
	end
	if global.version <4 then
		for a,b in pairs(global.turbines) do
			if b.base and b.base.valid then
				rendering.set_render_layer(b.turbine, "wires-above")
			end
		end
		global.version = 4
	end
	if settings.startup["ownly_windturbines_locked_power"].value then
		for a,b in pairs(global.turbines) do
			if b.base and b.base.valid then
				b.base.power_production = 750000/60*2^(b.level-1)
			end
		end
	end
end)

function entity_built(event)
    local entity = event.created_entity or event.entity
	if not turbine_names[entity.name] then return end
	
	local orientation = 16
    local position = entity.position
	local force = entity.force
	local surface = entity.surface
	local level = turbine_names[entity.name]
	entity.destroy()
	new_entity = surface.create_entity{name = "ownly_wind_turbine_mk"..level, position = position, force = force}
	
	collision_box = surface.create_entity{name = "ownly_wind_turbine_collision_box_mk"..level, position = {position.x+0,position.y-0}, force = force}
	collision_box.destructible = false
	collision_box.minable = false
	
	global.turbines[new_entity.unit_number] = {
		base = new_entity, 
		collision_box = collision_box,
		surface = surface.name, 
		orientation = 16, 
		level = level,
		turbine = rendering.draw_animation{animation =  "ownly_wind_turbine_mk"..level.."_"..orientation, target= {position.x,position.y-10}, surface = surface,animation_speed =surface.wind_speed*WIND_SPEED_MULT, render_layer = "wires-above"},
		shadow =  rendering.draw_animation{animation = "ownly_wind_turbine_shadow_"..orientation, target= {position.x+6,position.y-1}, surface = surface,animation_speed =surface.wind_speed*WIND_SPEED_MULT},
		last_change = game.tick,
		last_speed = surface.wind_speed*WIND_SPEED_MULT,
		creation_tick = game.tick,
		last_frame_count = 0,
		last_offset = 0,
		}
		--game.print("built at wind speed of "..surface.wind_speed*WIND_SPEED_MULT)
    ---- after anything is built/removed check around the turbines to see if we need to increase/reduce power
    --check_turbine_surroundings()
end

function entity_removed(event)
    local entity = event.entity
	if not turbine_names[entity.name] or not global.turbines[entity.unit_number] then return end
	destroy_turbine(entity.unit_number)
end

script.on_event(defines.events.on_built_entity, entity_built)
script.on_event(defines.events.on_robot_built_entity, entity_built)
script.on_event(defines.events.script_raised_revive, entity_built)

script.on_event(defines.events.on_player_mined_entity, entity_removed)
script.on_event(defines.events.on_entity_died, entity_removed)
script.on_event(defines.events.on_robot_mined_entity, entity_removed)

script.on_event(defines.events.on_entity_died, function(event)
	if script_kill then return end
    local entity = event.entity
	if not turbine_names[entity.name] or not global.turbines[entity.unit_number] then return end
	destroy_turbine(entity.unit_number, true)
end)

script.on_nth_tick(290, function(event)
	for a,b in pairs(game.surfaces) do
		b.wind_speed = math.max(0.001,(b.wind_speed -0.002+math.random()*0.004)*0.975+0.00052)
	end
end)

script.on_nth_tick(2, function(event)
	local wind_orientations = {}
	local wind_speeds = {}
	for a,b in pairs(game.surfaces) do
		wind_orientations[a] = math.floor(b.wind_orientation*32+0.499)
		if wind_orientations[a] > 31 then
			wind_orientations[a] = 0
		end
		wind_orientations[a] = (wind_orientations[a] + 16) %31
		wind_speeds[a] = b.wind_speed
	end
	
	local runs = math.min(1,table_size(global.turbines)/20 + (global.fractional_tick or 0))
	global.fractional_tick = runs % 1
	for i=1,runs do
		if global.iterate and not global.turbines[global.iterate] then
			global.iterate = nil
		end
		local remove_entry 
		if global.iterate then
			if not validate_turbine(global.iterate) then
				remove_entry = global.iterate
			else
				local turbine = global.turbines[global.iterate]
				if turbine.orientation ~= wind_orientations[turbine.surface] then
					local position = turbine.base.position
					local surface = turbine.base.surface
					local level = turbine.level
					local orientation = wind_orientations[turbine.surface]
					
					rendering.set_animation(turbine.turbine, "ownly_wind_turbine_mk"..level.."_"..orientation)
					rendering.set_animation(turbine.shadow, "ownly_wind_turbine_shadow_"..orientation)
					
					turbine.orientation = orientation
				end
				local current_wind_speed = wind_speeds[turbine.base.surface.name]*WIND_SPEED_MULT
				if turbine.last_speed ~= current_wind_speed then
					--game.print("new speed: "..current_wind_speed)
					local expected_frame = (((game.tick * turbine.last_speed) + turbine.last_offset) % 24)
					--game.print("currently at frame: "..expected_frame)
					local new_frame = (((game.tick * current_wind_speed)) % 24)
					--game.print("new frame w/o offset: "..new_frame)
					
					new_offset = (expected_frame - new_frame)%24
					--game.print("new offset: "..new_offset)
					--game.print(string.rep("-",game.tick%80))
					rendering.set_animation_speed(turbine.turbine,current_wind_speed )
					rendering.set_animation_speed(turbine.shadow,current_wind_speed)
					rendering.set_animation_offset(turbine.shadow,new_offset)
					rendering.set_animation_offset(turbine.turbine,new_offset)
					
					turbine.last_offset = new_offset			
					turbine.last_speed = current_wind_speed
					if not settings.startup["ownly_windturbines_locked_power"].value then
						turbine.base.power_production  = 750000/60*2^(turbine.level-1)*(current_wind_speed/0.457)
					end
				end
			end
			
		end
		global.iterate = next(global.turbines ,global.iterate)
		if not global.iterate then
			global.iterate = next(global.turbines ,global.iterate)
		end
		if remove_entry then
			destroy_turbine(remove_entry, true)
		end
	end
end)

function round(number)
	if number %1 >=0.5 then
		number = math.ceil(number)
	else
		number = math.floor(number)
	end
	return number
end

function validate_turbine(unit_number)
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
function destroy_turbine(unit_number, died)
	if not global.turbines[unit_number] then return end
	if died then
		if global.turbines[unit_number].base and global.turbines[unit_number].base.valid then
			script_kill = true
			global.turbines[unit_number].base.die(global.turbines[unit_number].base.force)
			script_kill = nil
		end
	elseif global.turbines[unit_number].base then
		global.turbines[unit_number].base.destroy()
	end
	rendering.destroy(global.turbines[unit_number].turbine)
	rendering.destroy(global.turbines[unit_number].shadow)
	
	if global.turbines[unit_number].collision_box then
		global.turbines[unit_number].collision_box.destroy()
	end
	
	global.turbines[unit_number]=nil

end