for _,render in pairs(rendering.get_all_ids("windturbines-redux")) do
    local found = false
    for _,turbine in pairs(global.turbines) do
        if turbine.turbine == render or turbine.shadow == render then
            found = true
        end
    end
    
    if found == false then
        rendering.destroy(render)
    end
end