-- HARDCORE BRIX minetest mod [Hardcore °Bx]
-- @link https://github.com/aa6/minetest_hardcorebrix
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib.file_exists.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib.file_get_contents.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib.file_put_contents.lua")
minetest_hardcorebrix = 
{
    worldconfig = minetest.get_worldpath().."/mod_minetest_hardcorebrix_config.lua",
}
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.log.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.config.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.functions.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.red_firebrick.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.white_firebrick.lua")