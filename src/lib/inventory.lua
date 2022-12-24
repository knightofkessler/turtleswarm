-----
-- Library of various inventory-related functions.
-- @author Brenden Lech
-- @author Joshua Fitzgerald

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
-- Tries to select the specified item (or an empty slot) in the inventory, optionally attempting to select
-- a slot that possesses at least a specified number of the item.
-- @tparam str identifier the namespaced identifier of the desired item. If identifier is empty/nil,
-- findItem will try to find an empty slot.
-- @tparam int number (optional) the minimum number of items that the slot must contain.
-- Defaults to 1. 
-- @treturn bool whether or not a slot with the desired item in the desired quantity exists
function inventory.findItem(identifier,number)

    number = number or 1

    for i = 1, NUM_SLOTS, 1 do
        turtle.select(i)

        local info = turtle.getItemDetail()

        if info then
            --If we are looking for an item, then we do these tests
            if info.name == identifier and info.count >= number then
                return true
            end
        else
            --If we are not looking for an item, then great, we found an empty slot
            if not identifier then
                return true
            end
        end
    end
    
    return false
end

-----
-- Attempts to select the largest stack of a specified resource
-- @tparam str identifier the namespaced identifier of the desired item.
-- @treturn int returns the size of the selected stack (which may be zero
-- if the resource does not exit)
function inventory.findLargestItemStack(identifier)
    local largestSize = 0
    local lastLargest = turtle.getSelectedSlot()

    while true do
      
        --We try to find a larger stack than the one we have 
        if inventory.findItem(identifier,largestSize+1) then
            --We need to save the slot in case things go awry
            largestSize = turtle.getItemDetail().count
            lastLargest = turtle.getSelectedSlot()
        else
            turtle.select(lastLargest)
            break
        end
    end

    return selectedSize

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
function inventory.getNumSlots()
    return NUM_SLOTS
end

return inventory