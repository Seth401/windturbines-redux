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

for _, surface in pairs(game.surfaces) do
    for level = 1, 3 do
        
        local cb = surface.find_entities_filtered{ name = ("ownly_wind_turbine_mk" .. level)}
        
        print("Found " .. #cb .. " number of turbiens of level " .. level .. " on surface " .. surface.name)
        
        for _,turbine in pairs(cb) do
            local entity = turbine
            
            if not turbineNames[entity.name] then
                return
            end
            
            local orientation = 16
            local position = entity.position
            local force = entity.force
            local surface = entity.surface
            local level = turbineNames[entity.name]
            --entity.destroy()
            
            local new_entity = turbine
            
            local collision_box = surface.find_entities_filtered{position = entity.position, type = "simple-entity-with-force"}[1]
            
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
    end
end