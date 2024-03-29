-- World-specific configs are available. To create world-specific config,
-- copy this file to `worlds/<worldname>/mod_minetest_hardcorebrix_config.lua`
-- Common config values.
minetest_hardcorebrix.ENABLE_INGAME_SETTINGS = true
-- Red firebrick configuration
minetest_hardcorebrix.RED_FIRED_CLAY_BRICK_DEFAULT_COOKING_TIME_SECONDS             = 60
minetest_hardcorebrix.WET_RED_FIREBRICK_DRYING_ATTEMPTS_ABM_INTERVAL_SECONDS        = 30
minetest_hardcorebrix.WET_RED_FIREBRICK_DRYING_CHANCE_SURROUNDING_LIGHT_FACTOR      = 2
minetest_hardcorebrix.CHANCE_OF_RED_FIREBRICK_BREAKING_BY_PICKAXE_PERCENTS          = 9
minetest_hardcorebrix.CHANCE_OF_WHITE_FIREBRICK_BREAKING_BY_PICKAXE_PERCENTS        = 13
minetest_hardcorebrix.CHANCE_OF_WET_RED_FIREBRICK_TO_START_DRYING_PROCESS_PERCENTS  = 80
minetest_hardcorebrix.CHANCE_OF_WET_RED_FIREBRICK_DRYING_IN_THE_TOTAL_DARK_PERCENTS = 10
-- White firebrick configuration
minetest_hardcorebrix.WHITE_FIRED_CLAY_BRICK_DEFAULT_COOKING_TIME_SECONDS             = minetest_hardcorebrix.RED_FIRED_CLAY_BRICK_DEFAULT_COOKING_TIME_SECONDS
minetest_hardcorebrix.WET_WHITE_FIREBRICK_DRYING_ATTEMPTS_ABM_INTERVAL_SECONDS        = minetest_hardcorebrix.WET_RED_FIREBRICK_DRYING_ATTEMPTS_ABM_INTERVAL_SECONDS
minetest_hardcorebrix.WET_WHITE_FIREBRICK_DRYING_CHANCE_SURROUNDING_LIGHT_FACTOR      = minetest_hardcorebrix.WET_RED_FIREBRICK_DRYING_CHANCE_SURROUNDING_LIGHT_FACTOR

minetest_hardcorebrix.CHANCE_OF_WET_WHITE_FIREBRICK_TO_START_DRYING_PROCESS_PERCENTS  = minetest_hardcorebrix.CHANCE_OF_WET_RED_FIREBRICK_TO_START_DRYING_PROCESS_PERCENTS
minetest_hardcorebrix.CHANCE_OF_WET_WHITE_FIREBRICK_DRYING_IN_THE_TOTAL_DARK_PERCENTS = minetest_hardcorebrix.CHANCE_OF_WET_RED_FIREBRICK_DRYING_IN_THE_TOTAL_DARK_PERCENTS