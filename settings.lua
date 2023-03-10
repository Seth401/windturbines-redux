data:extend(
    {
        {
            setting_type = "startup",
            name = "ownly_windturbines_low_vram",
            
            type = "bool-setting",
            default_value = false,
        },
        {
            setting_type = "runtime-global",
            name = "ownly_windturbines_locked_power",
            
            type = "bool-setting",
            default_value = false,
        },
        {
            setting_type = "runtime-global",
            name = "ownly_windturbines_vary_windspeed",
            
            type = "bool-setting",
            default_value = true,
        },
        {
            setting_type = "runtime-global",
            name = "ownly_windturbines_base_power",
            
            type = "double-setting",
            default_value = 750.0,
            minimum_value = 1.0,
        }
    }
)
