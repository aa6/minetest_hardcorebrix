-- Loading global config.
dofile(minetest.get_modpath(minetest.get_current_modname()).."/config.lua")

-- Processing in-game settings. In-game settings are preferrable
-- over global config.lua values.
function minetest_hardcorebrix.load_minetest_settings_key(key,type)
    if type == "int" then
        if minetest.settings:get("minetest_hardcorebrix."..key) ~= nil then
            minetest_hardcorebrix[key] = tonumber(minetest.settings:get("minetest_hardcorebrix."..key))
        end
    elseif type == "bool" then
        if minetest.settings:get_bool("minetest_hardcorebrix."..key) ~= nil then
            minetest_hardcorebrix[key] = minetest.settings:get_bool("minetest_hardcorebrix."..key)
        end
    end
end
minetest_hardcorebrix.load_minetest_settings_key("ENABLE_INGAME_SETTINGS","bool")
if minetest_hardcorebrix.ENABLE_INGAME_SETTINGS == true then
    minetest_hardcorebrix.log("In-game minetest settings are enabled. Loading them.")
    minetest_hardcorebrix.load_minetest_settings_key("RED_FIRED_CLAY_BRICK_DEFAULT_COOKING_TIME_SECONDS","int")
    minetest_hardcorebrix.load_minetest_settings_key("WHITE_FIRED_CLAY_BRICK_DEFAULT_COOKING_TIME_SECONDS","int")
    minetest_hardcorebrix.load_minetest_settings_key("CHANCE_OF_RED_FIREBRICK_BREAKING_BY_PICKAXE_PERCENTS","int")
    minetest_hardcorebrix.load_minetest_settings_key("CHANCE_OF_WHITE_FIREBRICK_BREAKING_BY_PICKAXE_PERCENTS","int")
    minetest_hardcorebrix.load_minetest_settings_key("WET_RED_FIREBRICK_DRYING_ATTEMPTS_ABM_INTERVAL_SECONDS","int")
    minetest_hardcorebrix.load_minetest_settings_key("WET_RED_FIREBRICK_DRYING_CHANCE_SURROUNDING_LIGHT_FACTOR","int")
    minetest_hardcorebrix.load_minetest_settings_key("WET_WHITE_FIREBRICK_DRYING_ATTEMPTS_ABM_INTERVAL_SECONDS","int")
    minetest_hardcorebrix.load_minetest_settings_key("WET_WHITE_FIREBRICK_DRYING_CHANCE_SURROUNDING_LIGHT_FACTOR","int")
    minetest_hardcorebrix.load_minetest_settings_key("CHANCE_OF_WET_RED_FIREBRICK_TO_START_DRYING_PROCESS_PERCENTS","int")
    minetest_hardcorebrix.load_minetest_settings_key("CHANCE_OF_WET_RED_FIREBRICK_DRYING_IN_THE_TOTAL_DARK_PERCENTS","int")
    minetest_hardcorebrix.load_minetest_settings_key("CHANCE_OF_WET_WHITE_FIREBRICK_TO_START_DRYING_PROCESS_PERCENTS","int")
    minetest_hardcorebrix.load_minetest_settings_key("CHANCE_OF_WET_WHITE_FIREBRICK_DRYING_IN_THE_TOTAL_DARK_PERCENTS","int")
else
    minetest_hardcorebrix.log("In-game minetest settings are disabled. Ignoring them.")
end

-- Processing world-specific config. World-specific values are preferrable 
-- over both global config and in-game settings.
if file_exists(minetest_hardcorebrix.worldconfig) then 
    minetest_hardcorebrix.log("Loading world-specific config: "..minetest_hardcorebrix.worldconfig)
    dofile(minetest_hardcorebrix.worldconfig)
else
    minetest_hardcorebrix.log("Creating world-specific config: "..minetest_hardcorebrix.worldconfig)
    local new_world_config_contents = 
        "-- World-specific config. Values are taken from `mods/minetest_hardcorebrix/config.lua`:\n"..
        "-- Please uncomment lines of your need and set the desired value.\n"
    for line in string.gmatch(file_get_contents(minetest.get_modpath(minetest.get_current_modname()).."/config.lua"), "[^\r\n]+") do
        if string.sub(line,0,string.len(minetest.get_current_modname())+1) == minetest.get_current_modname().."." then
            new_world_config_contents = new_world_config_contents.."-- "..line.."\n"
        end
    end
    file_put_contents(minetest_hardcorebrix.worldconfig,new_world_config_contents)
end