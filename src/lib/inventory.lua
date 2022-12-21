-----
-- Library of various inventory-related functions.
-- @author Brenden Lech

package.path = "/lib/?.lua;" .. package.path
require "utils"

-- The library table
inventory = {}

-- The number of slots in a turtle's inventory
local NUM_SLOTS = 16

-----
-- Refuels the turtle using all combustible items in its inventory
function inventory.refuel()
    utils.printlog("Refueling")
    for i = 1, NUM_SLOTS, 1 do
        turtle.select(i)
        turtle.refuel()
    end
end

-----
-- Returns whether every slot in the inventory has an item in it
-- @treturn bool whether every slot in the inventory has an item in it
function inventory.isInventoryFull()
    
    for i = 1, NUM_SLOTS, 1 do
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end
    
    return true
    
end

-----
-- Sorts the inventory, putting items of the same type in the same slots to save space
function inventory.sortInventory()
    
    for i = NUM_SLOTS, 1, -1 do
        if turtle.getItemDetail(i) then
            
            turtle.select(i)
            
            for j = 1, i, 1 do
                if turtle.compareTo(j) then
                    turtle.transferTo(j)
                end
            end
            
        end
    end
    
end

-----
-- Throws out items from the inventory that are on the given list onto the ground
-- @tparam tab trashList the table of item types to throw out, each entry formatted as ["namespace:item"]=true
function inventory.trashItems(trashList)
    
    utils.printlog("Trashing items")
    
    for i = 1, NUM_SLOTS, 1 do
        
        local itemInfo = turtle.getItemDetail(i)
        
        if not (itemInfo == nil) then
            if trashList[itemInfo["name"]] then
                turtle.select(i)
                assert(turtle.drop())
            end
        end
        
    end
    
end

-----
-- Returns the total number of slots in a turtle's inventory.
-- @treturn int the total number of slots in a turtle's inventory
function getNumSlots()
    return NUM_SLOTS
end

return inventory