-- When you need to change node name, changing a string.sub parameters 
-- cause a lot of troubles and inconveniences. That's why I decided to
-- put these numbers in constants.
local NODEBOXNUMPOS = string.len("minetest_hardcorebrix:node_white_firebrick_dry_damaged_X_nodeboxY")

------------------------------------------------------------------------
-- Called on node digging.
------------------------------------------------------------------------
function minetest_hardcorebrix.on_white_firebrick_node_dig(pos,node,digger)
    -- Fiwhite_brick has a chance not to break.
    if math.random(1,100) - minetest_hardcorebrix.CHANCE_OF_WHITE_FIREBRICK_BREAKING_BY_PICKAXE_PERCENTS < 1 then
        -- Randomly chosen that node must be breaked this time.
        if node.name == "minetest_hardcorebrix:node_white_firebrick_dry" then
            minetest.sound_play("minetest_hardcorebrix_firebrick_broken")
            minetest.swap_node(pos,{ name = "minetest_hardcorebrix:node_white_firebrick_dry_damaged_1" })
        elseif node.name == "minetest_hardcorebrix:node_white_firebrick_dry_damaged_1" then
            minetest.sound_play("minetest_hardcorebrix_firebrick_broken")
            minetest.swap_node(pos,{ name = "minetest_hardcorebrix:node_white_firebrick_dry_damaged_2" })
        elseif node.name == "minetest_hardcorebrix:node_white_firebrick_dry_damaged_2" then
            -- After this damage level a nodeboxnum must be defined and 
            -- used to keep destructions the same (standard destruction 
            -- nodebox angle and orientation).
            local nodeboxnum = minetest_hardcorebrix.analyze_surrounding_white_firebricks_and_return_best_nodebox_number(pos) 
            minetest.sound_play("minetest_hardcorebrix_firebrick_broken")
            minetest.swap_node(pos,{ name = "minetest_hardcorebrix:node_white_firebrick_dry_damaged_3_nodebox"..nodeboxnum })
        elseif string.sub(node.name,1,NODEBOXNUMPOS - 9) == "minetest_hardcorebrix:node_white_firebrick_dry_damaged_3" then
            local nodeboxnum = string.sub(node.name,NODEBOXNUMPOS,NODEBOXNUMPOS)
            minetest.sound_play("minetest_hardcorebrix_firebrick_broken")
            minetest.swap_node(pos,{ name = "minetest_hardcorebrix:node_white_firebrick_dry_damaged_4_nodebox"..nodeboxnum })
        elseif string.sub(node.name,1,NODEBOXNUMPOS - 9) == "minetest_hardcorebrix:node_white_firebrick_dry_damaged_4" then
            local nodeboxnum = string.sub(node.name,NODEBOXNUMPOS,NODEBOXNUMPOS)
            minetest.sound_play("minetest_hardcorebrix_firebrick_broken")
            minetest.swap_node(pos,{ name = "minetest_hardcorebrix:node_white_firebrick_dry_damaged_5_nodebox"..nodeboxnum })
        elseif string.sub(node.name,1,NODEBOXNUMPOS - 9) == "minetest_hardcorebrix:node_white_firebrick_dry_damaged_5" then
            minetest.sound_play("minetest_hardcorebrix_firebrick_destroyed")
            minetest.remove_node(pos)
        end
    else
        -- Randomly chosen that node must stay unbreaked. We must fill
        -- an after-breaking empty space with the old node.
        minetest.swap_node(pos,node)
    end
end

------------------------------------------------------------------------
-- Looks for red firebrick nodes around pos and exclude from numbers_left 
-- these which already present nearly. This is used to avoid tile repeating.
------------------------------------------------------------------------
function minetest_hardcorebrix.analyze_surrounding_white_firebricks_and_return_best_nodebox_number(pos)
    local node
    local numbers_left = {1,2,3,4,5,6,7,8}
    -- Iterating through surrounding nodes.
    for offsetSideKey,offsetSide in pairs({"x","y","z"}) do
        for offsetValKey,offsetVal in pairs({1,-1}) do
            pos[offsetSide] = pos[offsetSide] + offsetVal
            node = minetest.get_node_or_nil(pos)
            pos[offsetSide] = pos[offsetSide] - offsetVal
            if node ~= nil then
                if string.sub(node.name,NODEBOXNUMPOS - 7,NODEBOXNUMPOS - 1) == "nodebox" then
                    numbers_left[tonumber(string.sub(node.name,NODEBOXNUMPOS,NODEBOXNUMPOS))] = false
                end
            end
        end
    end
    -- Fetching numbers left.
    local result_numbers = {}
    for key,number in pairs(numbers_left) do
        if(number ~= false) then
            result_numbers[#result_numbers + 1] = number
        end
    end
    -- Returning random result_numbers number.
    return result_numbers[math.random(#result_numbers)]
end

------------------------------------------------------------------------
-- ITEM: White clay brick.
------------------------------------------------------------------------
minetest.register_craftitem("minetest_hardcorebrix:item_white_clay_brick",
{
    description     = "White Clay Brick",
    inventory_image = "minetest_hardcorebrix_item_white_clay_brick.png",
})

minetest.register_craft(
{
    type = "shapeless",
    output = "minetest_hardcorebrix:item_white_clay_brick 1",
    recipe = 
    {
       "default:sand" , "default:clay_lump"
    }
})

------------------------------------------------------------------------
-- ITEM: Fired clay brick.
------------------------------------------------------------------------
minetest.register_craftitem("minetest_hardcorebrix:item_white_fired_clay_brick",
{
    description     = "White Fired Clay Brick",
    inventory_image = "minetest_hardcorebrix_item_white_fired_clay_brick.png",
    -- Player can repair damaged fired brick blocks by right-clicking
    -- on these blocks with this item.
    on_place = function(itemstack,placer,pointed_thing)
        if pointed_thing.type == "node" then
            local node = minetest.get_node(pointed_thing.under)
            if string.sub(node.name,1,NODEBOXNUMPOS - 11) == "minetest_hardcorebrix:node_white_firebrick_dry_damaged" then
                local damagelevel = tonumber(string.sub(node.name,NODEBOXNUMPOS - 9,NODEBOXNUMPOS - 9))
                local itemstackcount = itemstack:get_count()
                if itemstackcount >= damagelevel then
                    -- Cannot replace with wet fired brick block because it'll create an easy way 
                    -- to break fired brick walls by repairing it and then digging out wet blocks
                    minetest.swap_node(pointed_thing.under,{ name = "minetest_hardcorebrix:node_white_firebrick_dry" })
                    return ItemStack("minetest_hardcorebrix:item_white_fired_clay_brick "..(itemstackcount - damagelevel))
                end
            end
        end
    end
})

minetest.register_craft(
{
    output   = "minetest_hardcorebrix:item_white_fired_clay_brick 1",
    type     = "cooking",
    recipe   = "minetest_hardcorebrix:item_white_clay_brick",
    cooktime = minetest_hardcorebrix.WHITE_FIRED_CLAY_BRICK_DEFAULT_COOKING_TIME_SECONDS,
})

------------------------------------------------------------------------
-- NODE: White Firebrick Block (Wet)
------------------------------------------------------------------------
minetest.register_node("minetest_hardcorebrix:node_white_firebrick_wet",
{
    description = "White Firebrick Block (Wet)",
    tiles       = { "minetest_hardcorebrix_node_white_firebrick_wet.png" },
    groups      = { oddly_breakable_by_hand = 3 },
    sounds      = default.node_sound_stone_defaults(),
})

minetest.register_craft(
{
    output = "minetest_hardcorebrix:node_white_firebrick_wet 1",
    recipe = 
    {
        { "minetest_hardcorebrix:item_white_fired_clay_brick" , "minetest_hardcorebrix:item_white_fired_clay_brick" },
        { "default:clay_lump"                               , "default:clay_lump"                                   },
        { "minetest_hardcorebrix:item_white_fired_clay_brick" , "minetest_hardcorebrix:item_white_fired_clay_brick" },
    }
})

minetest.register_abm(
{
    nodenames = { "minetest_hardcorebrix:node_white_firebrick_wet" },
    interval  = minetest_hardcorebrix.WET_WHITE_FIREBRICK_DRYING_ATTEMPTS_ABM_INTERVAL_SECONDS,
    chance    = 100 - minetest_hardcorebrix.CHANCE_OF_WET_WHITE_FIREBRICK_TO_START_DRYING_PROCESS_PERCENTS,
    action    = function(pos, node, active_object_count, active_object_count_wider)
        -- The more light surrounds block - the faster it would get dry
        -- surrounding node lighting can be from 0 to 6*15=90 (sides * MAX_LIGHT)
        -- minetest_hardcorebrix.CHANCE_OF_DRYING_WET_FRIED_BRICKS_IN_THE_TOTAL_DARK_PERCENT 
        -- is added to give a chance of drying of a non-lighted block.
        if
            (
                math.random(0,100) - 
                (
                    (
                        minetest_hardcorebrix.get_surrounding_node_lighting(pos) * 
                        minetest_hardcorebrix.WET_WHITE_FIREBRICK_DRYING_CHANCE_SURROUNDING_LIGHT_FACTOR
                    ) + 
                    minetest_hardcorebrix.CHANCE_OF_WET_WHITE_FIREBRICK_DRYING_IN_THE_TOTAL_DARK_PERCENTS
                )
            ) < 0
        then
            minetest.set_node(pos,{ name = "minetest_hardcorebrix:node_white_firebrick_dry" })
        end
    end,
})

------------------------------------------------------------------------
-- NODE: White Firebrick Block
------------------------------------------------------------------------
minetest.register_node("minetest_hardcorebrix:node_white_firebrick_dry",
{
    description    = "White Firebrick Block",
    drop           = "",
    tiles          = { "minetest_hardcorebrix_node_white_firebrick_dry.png" },
    groups         = { cracky = 1, stone = 1 },
    sounds         = default.node_sound_stone_defaults(),
    on_blast       = minetest_hardcorebrix.on_node_blast,
    after_destruct = minetest_hardcorebrix.on_node_dig,
    node_dig_prediction = "minetest_hardcorebrix:node_white_firebrick_dry",
    --node_dig_prediction = "minetest_hardcorebrix:node_white_firebrick_dry"
})

------------------------------------------------------------------------
-- NODE: White Firebrick Block (Damaged 1 times)
------------------------------------------------------------------------
minetest.register_node("minetest_hardcorebrix:node_white_firebrick_dry_damaged_1",
{
    description    = "White Firebrick Block (Damaged 1 times)",
    drop           = "",
    tiles          = { "minetest_hardcorebrix_node_white_firebrick_dry_damaged_1.png" },           
    groups         = { cracky = 1, stone = 1 },
    sounds         = default.node_sound_stone_defaults(),
    on_blast       = minetest_hardcorebrix.on_node_blast,
    after_destruct = minetest_hardcorebrix.on_node_dig,
    node_dig_prediction = "minetest_hardcorebrix:node_white_firebrick_dry_damaged_1",
})

------------------------------------------------------------------------
-- NODE: White Firebrick Block (Damaged 2 times)
------------------------------------------------------------------------
minetest.register_node("minetest_hardcorebrix:node_white_firebrick_dry_damaged_2",
{
    description    = "White Firebrick Block (Damaged 2 times)",
    drop           = "",
    tiles          = { "minetest_hardcorebrix_node_white_firebrick_dry_damaged_2.png" },           
    groups         = { cracky = 1, stone = 1 },
    sounds         = default.node_sound_stone_defaults(),
    on_blast       = minetest_hardcorebrix.on_node_blast,
    after_destruct = minetest_hardcorebrix.on_node_dig,
    node_dig_prediction = "minetest_hardcorebrix:node_white_firebrick_dry_damaged_2",
})

------------------------------------------------------------------------
-- NODE: White Firebrick Block (Damaged 3 times), 6 variants of rotation
------------------------------------------------------------------------
local nodeboxes = {}
local nodebox =
{
    { -0.5 ,  0   ,  0   , 0   , 0.5 , 0.5 }, -- Top1
    {  0   ,  0   ,  0   , 0.5 , 0.5 , 0.5 }, -- Top2
    {  0   ,  0   , -0.5 , 0.5 , 0.5 , 0   }, -- Top3
--  { -0.5 ,  0   , -0.5 , 0   , 0.5 , 0   }, -- Top4
    { -0.5 , -0.5 ,  0   , 0   , 0   , 0.5 }, -- Bottom1
    {  0   , -0.5 ,  0   , 0.5 , 0   , 0.5 }, -- Bottom2
    {  0   , -0.5 , -0.5 , 0.5 , 0   , 0   }, -- Bottom3
    { -0.5 , -0.5 , -0.5 , 0   , 0   , 0   }, -- Bottom4
}

table.foreach({0, math.pi * 1/2,  math.pi, math.pi * 3/2},function(nodeRotateIndex,nodeRotateAngle)
    nodeboxes[nodeRotateIndex] = minetest_hardcorebrix.rotate_nodebox_clockwise(nodebox,"y",nodeRotateAngle)
    nodeboxes[nodeRotateIndex] = minetest_hardcorebrix.optimize_nodebox(nodeboxes[nodeRotateIndex])
end)
table.foreach(nodeboxes,function(nodeBoxIndex,nodeBox)
    if((nodeBoxIndex + 4) > 8) then return end -- Caution: endless foreach as it push new items to nodeboxes.
    nodeboxes[nodeBoxIndex + 4] = minetest_hardcorebrix.flip_nodebox(nodeBox,"y") 
end)

for index,nodeboxBox in pairs(nodeboxes) do
    minetest.register_node(
        "minetest_hardcorebrix:node_white_firebrick_dry_damaged_3_nodebox"..index,
        {
            description = "Red Firebrick Block (Damaged 3 times)",
            drop        = "",
            tiles       = { "minetest_hardcorebrix_node_white_firebrick_dry_damaged_2.png" },
            groups      = { cracky = 1, stone = 1 },
            sounds      = default.node_sound_stone_defaults(),
            drawtype    = "nodebox",
            paramtype   = "light",
            node_box    = 
            {
                type  = "fixed",
                fixed = nodeboxBox,
            },
            on_blast       = minetest_hardcorebrix.on_node_blast,
            after_destruct = minetest_hardcorebrix.on_node_dig,
            node_dig_prediction = "minetest_hardcorebrix:node_white_firebrick_dry_damaged_3_nodebox"..index,
        }
    )
end

------------------------------------------------------------------------
-- NODE: White Firebrick Block (Damaged 4 times), 6 variants of rotation
------------------------------------------------------------------------
local nodeboxes = {}
local nodebox =
{
    { -0.5 ,  0   ,  0   , 0   , 0.5 , 0.5 }, -- Top1
    {  0   ,  0   ,  0   , 0.5 , 0.5 , 0.5 }, -- Top2
--  {  0   ,  0   , -0.5 , 0.5 , 0.5 , 0   }, -- Top3
--  { -0.5 ,  0   , -0.5 , 0   , 0.5 , 0   }, -- Top4
    { -0.5 , -0.5 ,  0   , 0   , 0   , 0.5 }, -- Bottom1
    {  0   , -0.5 ,  0   , 0.5 , 0   , 0.5 }, -- Bottom2
    {  0   , -0.5 , -0.5 , 0.5 , 0   , 0   }, -- Bottom3
    { -0.5 , -0.5 , -0.5 , 0   , 0   , 0   }, -- Bottom4
}

table.foreach({0, math.pi * 1/2,  math.pi, math.pi * 3/2},function(nodeRotateIndex,nodeRotateAngle)
    nodeboxes[nodeRotateIndex] = minetest_hardcorebrix.rotate_nodebox_clockwise(nodebox,"y",nodeRotateAngle)
    nodeboxes[nodeRotateIndex] = minetest_hardcorebrix.optimize_nodebox(nodeboxes[nodeRotateIndex])
end)
table.foreach(nodeboxes,function(nodeBoxIndex,nodeBox)
    if((nodeBoxIndex + 4) > 8) then return end -- Caution: endless foreach as it push new items to nodeboxes.
    nodeboxes[nodeBoxIndex + 4] = minetest_hardcorebrix.flip_nodebox(nodeBox,"y")
end)

for index,nodeboxBox in pairs(nodeboxes) do
    minetest.register_node(
        "minetest_hardcorebrix:node_white_firebrick_dry_damaged_4_nodebox"..index,
        {
            description = "Red Firebrick Block (Damaged 4 times)",
            drop        = "",
            tiles       = { "minetest_hardcorebrix_node_white_firebrick_dry_damaged_2.png" },
            groups      = { cracky = 1, stone = 1 },
            sounds      = default.node_sound_stone_defaults(),
            drawtype    = "nodebox",
            paramtype   = "light",
            node_box    = 
            {
                type  = "fixed",
                fixed = nodeboxBox,
            },
            on_blast       = minetest_hardcorebrix.on_node_blast,
            after_destruct = minetest_hardcorebrix.on_node_dig,
            node_dig_prediction = "minetest_hardcorebrix:node_white_firebrick_dry_damaged_4_nodebox"..index,
        }
    )
end

------------------------------------------------------------------------
-- NODE: White Firebrick Block (Damaged 5 times), 6 variants of rotation
------------------------------------------------------------------------
local nodeboxes = {}
local nodebox =
{
    { -0.5 ,  0   ,  0   , 0   , 0.5 , 0.5 }, -- Top1
    {  0   ,  0   ,  0   , 0.5 , 0.5 , 0.5 }, -- Top2
--  {  0   ,  0   , -0.5 , 0.5 , 0.5 , 0   }, -- Top3
--  { -0.5 ,  0   , -0.5 , 0   , 0.5 , 0   }, -- Top4
    { -0.5 , -0.5 ,  0   , 0   , 0   , 0.5 }, -- Bottom1
    {  0   , -0.5 ,  0   , 0.5 , 0   , 0.5 }, -- Bottom2
--  {  0   , -0.5 , -0.5 , 0.5 , 0   , 0   }, -- Bottom3
    { -0.5 , -0.5 , -0.5 , 0   , 0   , 0   }, -- Bottom4
}

table.foreach({0, math.pi * 1/2,  math.pi, math.pi * 3/2},function(nodeRotateIndex,nodeRotateAngle)
    nodeboxes[nodeRotateIndex] = minetest_hardcorebrix.rotate_nodebox_clockwise(nodebox,"y",nodeRotateAngle)
    nodeboxes[nodeRotateIndex] = minetest_hardcorebrix.optimize_nodebox(nodeboxes[nodeRotateIndex])
end)
table.foreach(nodeboxes,function(nodeBoxIndex,nodeBox)
    if((nodeBoxIndex + 4) > 8) then return end -- Caution: endless foreach as it push new items to nodeboxes.
    nodeboxes[nodeBoxIndex + 4] = minetest_hardcorebrix.flip_nodebox(nodeBox,"y")
end)

for index,nodeboxBox in pairs(nodeboxes) do
    minetest.register_node(
        "minetest_hardcorebrix:node_white_firebrick_dry_damaged_5_nodebox"..index,
        {
            description = "Red Firebrick Block (Damaged 5 times)",
            drop        = "",
            tiles       = { "minetest_hardcorebrix_node_white_firebrick_dry_damaged_2.png" },
            groups      = { cracky = 1, stone = 1 },
            sounds      = default.node_sound_stone_defaults(),
            drawtype    = "nodebox",
            paramtype   = "light",
            node_box    = 
            {
                type  = "fixed",
                fixed = nodeboxBox,
            },
            on_blast       = minetest_hardcorebrix.on_node_blast,
            after_destruct = minetest_hardcorebrix.on_node_dig,
            node_dig_prediction = "minetest_hardcorebrix:node_white_firebrick_dry_damaged_5_nodebox"..index,
        }
    )
end