-----
-- Library of crafting-related functions.
--
-- Throughout this package, crafting recipes should be specified 
-- as a table whose (integer) indices correspond to turtle inventory slots (assume a 
-- 4x4 grid, but only the slots in ) and whose (string) entries correspond to item identifiers. Empty slots
-- should be left as nil (which means they don't have to be defined explicitly)
-- @author Joshua Fitzgerald

package.path = "/lib/?.lua;" .. package.path
require "utils"
require "inventory"

-- The library table
craft = {}

-- These are the slots which we are always going to use for crafting.
--Any recipes that contain slots not on this list will be rejected.
local CRAFTING_SLOTS = {1,2,3,5,6,7,9,10,11}

-----
-- Attempts to craft the recipe provided in the format above.
-- DISCARDS SOME ITEMS NOT USED FOR CRAFTING THE RECIPE WITHOUT
-- MAKING SURE THEY ARE SAFELY RETRIEVABLE!
-- @tparam table recipe The recipe to craft
-- @treturn bool Whether crafting succeeded
function craft.craftRecipe(recipe)

    -- If the recipe contains an illegal crafting position, it will be thrown out
    for position, item in pairs(recipe) do
        local legal = false
        for _, craftingSlot in pairs(CRAFTING_SLOTS) do
            if position == craftingSlot then
                legal = true
                break
            end
        end
        if not legal then
            error("Crafting recipe contains disallowed turtle inventory slot number. " ..
                  "Run craft.getCraftingSlots() to get a list of permitted slots.")
        end
    end
    
    -- We sort the inventory to try to reduce the number of slots
    inventory.sortInventory()

    --We throw out all the item types that we don't need
    for i = 1, inventory.getNumSlots(), 1 do
        
        turtle.select(i)

        local selectionInfo = turtle.getItemDetail() 

        local isUsed = false
        for _, item in pairs(recipe) do
            -- If we find that the item is in the recipe, then we need to keep looking
            if selectionInfo and selectionInfo.name == item then
                isUsed = true
                break
            end
        end

        if not isUsed then
            -- If we made it here, then we looked through all the items in the recipe and none of them
            -- matched the item in the slot, so we assume that the current i can be thrown out.
            turtle.drop()
        end
        
    end
    
    -- Now that we have cleaned up the inventory, we can start making the recipe. 
    -- Before removing the extraneous items, we just put the items we need into position.
    for position, item in pairs(recipe) do
        turtle.select(position)

        --If the item is already in position, we don't need to do the ensuing code
        selectedItem = turtle.getItemDetail()
        if not selectedItem or selectedItem.name ~= item then

            --If we don't have any free slots, then we just give up 
            if not(inventory.findItem()) then
                return false
            end 

            --But, if we did find a free slot, we transfer the stuff in the slot under consideration to it
            local freeSlot = turtle.getSelectedSlot()

            turtle.select(position)
            turtle.transferTo(freeSlot)

            -- Now, we try to find the materials that we need. We always try to use the largest stack. 
            -- If we can't find the materials, we quit trying and return false
            if inventory.findLargestItemStack(item) == 0 then
                return false
            end

            -- But, if we can find the materials, they're now selected, so we put just one item in the slot needed
            turtle.transferTo(position,1)
        end

    end

    -- We now loop through the slots and remove the contents of any slots not in the recipe
    for i = 1, inventory.getNumSlots(), 1 do

        -- We get info about the current slot and see whether it should be empty. If so, we
        -- drop its contents.
        if not recipe[i] then
            turtle.select(i)
            turtle.drop()
        end
    end

    --Hopefully things should be in the proper positions now, so we try to craft the thing
    return turtle.craft()

end

-----
-- Returns a table containing the inventory slots that recipes are allowed to use. Any recipe that
-- tries to use slots not on this list will be rejected.
-- @treturn table The crafting slots available for recipes to use
function craft.getCraftingSlots()
     return CRAFTING_SLOTS
end