------------------------------------------------------------------------
-- Must be called whenever anyone needs mod natural reaction when an 
-- explosion touches the node
------------------------------------------------------------------------
function minetest_hardcorebrix.on_node_blast(pos,intensity)
  -- TODO
end

------------------------------------------------------------------------
-- Optimizes nodebox
------------------------------------------------------------------------
--
--  __ ___ ___             __ ___ ___
-- |1|2__|3___|           |1|2_______|
-- | |      |4|      \    | |      |3|
-- | |______| |  =====\   | |______| |
-- |_|5_____| |  =====/   | |4_____| |
-- |6|      | |      /    | |      | |
-- |_|      |_|           |_|      |_|
-- 
-- Nodebox is an array of 3d-boxes coordinates.
-- Each box of a nodebox is defined as: { x1, y1, z1, x2, y2, z2 }.
--
------------------------------------------------------------------------
function minetest_hardcorebrix.optimize_nodebox(nodebox)
    -- Normalize box points by selecting min and max axis values.
    local normalized_nodebox = {}
    for index, box in pairs(nodebox) do
        local point_min = {
            x = math.min(box[1],box[4]),
            y = math.min(box[2],box[5]),
            z = math.min(box[3],box[6]),
        }
        local point_max = {
            x = math.max(box[1],box[4]),
            y = math.max(box[2],box[5]),
            z = math.max(box[3],box[6]),
        }
        table.insert(normalized_nodebox, 
        { 
            point_max = point_max,
            point_min = point_min, 
        })
    end
    -- Merge normalized boxes to each other by finding a parallell axis.
    local parallell_axis
    local current_pos = 1
    local current_box = normalized_nodebox[current_pos]
    repeat
        -- Compare current_box to other boxes.
        for index, box in pairs(normalized_nodebox) do
            if index > current_pos 
            and current_box ~= false 
            and box ~= false then
                if  current_box.point_max.x == box.point_max.x 
                and current_box.point_min.x == box.point_min.x 
                and current_box.point_max.y == box.point_max.y
                and current_box.point_min.y == box.point_min.y then
                    parallell_axis = "z"
                elseif  
                    current_box.point_max.x == box.point_max.x 
                and current_box.point_min.x == box.point_min.x 
                and current_box.point_max.z == box.point_max.z
                and current_box.point_min.z == box.point_min.z then
                    parallell_axis = "y"
                elseif  
                    current_box.point_max.y == box.point_max.y 
                and current_box.point_min.y == box.point_min.y 
                and current_box.point_max.z == box.point_max.z
                and current_box.point_min.z == box.point_min.z then
                    parallell_axis = "x"
                else
                    parallell_axis = nil
                end
                -- Merge boxes by parallell axis
                if parallell_axis ~= nil then
                    if current_box.point_max[parallell_axis] <= box.point_min[parallell_axis] then
                        -- If current_box is below the box or collides with it.
                        --  _______________ _______ 
                        -- |__current_box__|__box__|
                        --
                        normalized_nodebox[index] = false
                        normalized_nodebox[current_pos] = false
                        table.insert(normalized_nodebox,
                        { 
                            point_max = box.point_max,
                            point_min = current_box.point_min, 
                        })
                        -- Break for...ipairs.
                        break
                    elseif box.point_max[parallell_axis] <= current_box.point_min[parallell_axis] then
                        -- If current_box is above the box or collides with it.
                        --  _______ _______________ 
                        -- |__box__|__current_box__|
                        --
                        normalized_nodebox[index] = false
                        normalized_nodebox[current_pos] = false
                        table.insert(normalized_nodebox,
                        { 
                            point_max = current_box.point_max,
                            point_min = box.point_min, 
                        })
                        -- Break for...ipairs.
                        break
                    end
                end
                
            end
        end
        -- Move to next current_box.
        current_pos = current_pos + 1
        current_box = normalized_nodebox[current_pos]
    until current_box == nil
    -- Filter and transform normalized_nodebox values to an actual result.
    local result_nodebox = {}
    for index, box in pairs(normalized_nodebox) do
        if box ~= false then
            table.insert(result_nodebox,
            {
                box.point_min.x, box.point_min.y, box.point_min.z, 
                box.point_max.x, box.point_max.y, box.point_max.z, 
            })
        end
    end
    -- Return result.
    return result_nodebox
end

------------------------------------------------------------------------
-- Must be called whenever anyone needs mod natural reaction on its 
-- node breaking.
------------------------------------------------------------------------
--
--    Fired_brick node do not use on_dig function and rely on default
--    minetest.node_dig (minetest-master/builtin/game/item.lua) code 
--    that called each time when node is digged by pickaxe or something 
--    else. That is a reason why we need to swap node with itself when 
--    it must stay unbreaked: it is implied that node is already 
--    removed by default minetest.node_dig function.
--
------------------------------------------------------------------------
function minetest_hardcorebrix.on_node_dig(pos,node,digger)
    -- Describes different stages of fired_brick breaking.
    if     string.sub(node.name,1,44) == "minetest_hardcorebrix:node_red_firebrick_dry" then
        minetest_hardcorebrix.on_red_firebrick_node_dig(pos,node,digger)
    elseif string.sub(node.name,1,46) == "minetest_hardcorebrix:node_white_firebrick_dry" then
        minetest_hardcorebrix.on_white_firebrick_node_dig(pos,node,digger)
    end
end

------------------------------------------------------------------------
-- Gets cumulative surrounding nodes lighting 
------------------------------------------------------------------------
--
--    Maximum return lighting value == 15 light * 6 sides == 90
--
------------------------------------------------------------------------
function minetest_hardcorebrix.get_surrounding_node_lighting(pos,timeofday)
    local node_light
    local ligthing = 0
    table.foreach({"x","y","z"},function(offsetSideKey,offsetSide)
        table.foreach({1,-1},function(offsetValKey,offsetVal)
            pos[offsetSide] = pos[offsetSide] + offsetVal
            node_light = minetest.get_node_light(pos,timeofday)
            if node_light ~= nil then  -- tonumber(nil) returns nil
                ligthing = ligthing + node_light
            end
            pos[offsetSide] = pos[offsetSide] - offsetVal
        end)
    end)
    return ligthing
end

------------------------------------------------------------------------
-- Rotates nodebox clockwise.
------------------------------------------------------------------------
--
--    Nodebox definition: {x1, y1, z1, x2, y2, z2}
--    Used formulas:
-- 
--    y      x(A+B) = xA*cos(b) - yA*sin(b)
--     \__x  y(A+B) = xA*sin(b) + yA*cos(b)
-- 
--    Rotatedef (clockwise) explaination:
--             _____      _____      _____   
--            /y+  /\    /z+  /\    /x+  /\  
--           /____/  \  /____/  \  /____/  \
--    y      \z-  \x+/  \x-  \y+/  \y-  \z+/
--     \__x   \____\/    \____\/    \____\/
-- 
-- WARNING: Things are fucking up when anglerad is not multiple of 
--          (1/2 * math.pi). I have no idea why.
--
------------------------------------------------------------------------
function minetest_hardcorebrix.rotate_nodebox_clockwise(nodebox,axis,anglerad)
    local newNodeBox = {}
    local rotatedef = 
          {
              z = { y = "y", x = "x" },
              x = { y = "z", x = "y" },
              y = { y = "x", x = "z" },
          }
    function rotate_box_clockwise(box,axis,anglerad)
        local dot1,dot2,oldx,oldy
        dot1 = { x = box[1], y = box[2], z = box[3] }
        dot2 = { x = box[4], y = box[5], z = box[6] }
        table.foreach({dot1,dot2},function(dotIndex,dot)
            oldx = dot[rotatedef[axis].x]
            oldy = dot[rotatedef[axis].y]
            dot[rotatedef[axis].x] = minetest_hardcorebrix.math_round((oldx * math.cos(anglerad)) - (oldy * math.sin(anglerad)),3)
            dot[rotatedef[axis].y] = minetest_hardcorebrix.math_round((oldx * math.sin(anglerad)) + (oldy * math.cos(anglerad)),3)
        end)
        return { dot1.x, dot1.y, dot1.z, dot2.x, dot2.y, dot2.z }
    end
    table.foreach(nodebox,function(nodeIndex)
        newNodeBox[nodeIndex] = rotate_box_clockwise(nodebox[nodeIndex],axis,anglerad)
    end)
    return newNodeBox
end

------------------------------------------------------------------------
-- Flips nodebox
------------------------------------------------------------------------
--
--       ________                    ________
--      /3      /\                  /1      /\
--     /2      /  \         \      /2      /  \
--    /1______/    \    =====\    /3______/    \
--    \       \    /    =====/    \       \    /
--     \ axis  \  /         /      \ axis  \  /
--      \_______\/                  \_______\/
-- 
------------------------------------------------------------------------
function minetest_hardcorebrix.flip_nodebox(nodebox,axis)
    local newNodeBox = {}
    function flip_box(box,axis)
        local dot1
        local dot2
        dot1 = { x = box[1], y = box[2], z = box[3] }
        dot2 = { x = box[4], y = box[5], z = box[6] }
        dot1[axis] = -dot1[axis]
        dot2[axis] = -dot2[axis]
        return { dot1.x, dot1.y, dot1.z, dot2.x, dot2.y, dot2.z }
    end
    table.foreach(nodebox,function(nodeIndex)
        newNodeBox[nodeIndex] = flip_box(nodebox[nodeIndex],axis)
    end)
    return newNodeBox
end

------------------------------------------------------------------------
-- Lua developers has forgot to add math.round function
------------------------------------------------------------------------
function minetest_hardcorebrix.math_round(val, decimal)
    local exp = decimal and 10^decimal or 1
    return math.ceil(val * exp - 0.5) / exp
end