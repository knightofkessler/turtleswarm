-----
-- Module of crafting-related functions.
--
-- Throughout this package, crafting recipes should be specified as a table whose (integer) indices 
-- correspond to crafting table slots (in the way depicted below) whose (string) entries correspond 
-- to item identifiers. Empty slots should be left as nil (which means they don't have to be defined explicitly)
-- 
-- Indices refer to the following slots:
-- 1 2 3
-- 4 5 6
-- 7 8 9
--
-- @author Joshua Fitzgerald

package.path = "/modules/?.lua;" .. package.path
require "utils"
require "inventory"

-- The module table
craft = {}

-----
-- Attempts to craft the recipe provided.
-- DISCARDS SOME ITEMS NOT USED FOR CRAFTING THE RECIPE WITHOUT
-- MAKING SURE THEY ARE SAFELY RETRIEVABLE!
-- @tparam table recipe The recipe to craft, provided in crafting table notation
-- @treturn boolean Whether crafting succeeded
-- @treturn string A failure reason explaining why crafting failed
function craft.craftRecipe(recipe)

    -- For most of this function, we will use a version of the recipe that has been converted to
    -- turtle inventory notation, which assumes a 4x4 grid instead of a 3x3 grid
    local recipeTN = {}
    for position, item in pairs(recipe) do
        newposition = position + math.floor((position - 1) / 3)
        if 1 <= newposition and newposition <= 16 then
            recipeTN[newposition] = item
        else
            return false, "Disallowed index in crafting recipe: " .. position
        end
    end
    
    -- We sort the inventory to try to reduce the number of slots
    inventory.sortInventory()

    -- Since we've centralized our resources, we can now make sure that we have enough
    -- on hand to meet the crafting recipe's requirements.
    -- Note: this code will not work with strange crafting recipes where 
    -- the required number of an item to be used exceeds its max stack size
    recipeRequirements = craft.computeRecipeRequirements(recipeTN)
    for item, amount in pairs(recipeRequirements) do
        -- If we don't have a stack with enough of some resource, we don't try to craft
        -- the recipe
        if inventory.findLargestItemStack(item) < amount then
            return false, "Insufficient quantity of resource: " .. item;
        end
    end

    --We throw out all the item types that we don't need
    for i = 1, inventory.getNumSlots(), 1 do
        
        turtle.select(i)

        local selectionInfo = turtle.getItemDetail() 

        local isUsed = false
        for _, item in pairs(recipeTN) do
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
    for position, item in pairs(recipeTN) do
        turtle.select(position)

        --If the item is already in position, we don't need to do the ensuing code
        selectedItem = turtle.getItemDetail()
        if not selectedItem or selectedItem.name ~= item then

            --If we don't have any free slots, then we just give up 
            if not(inventory.findItem()) then
                return false, "No free slots remaining"
            end 

            --But, if we did find a free slot, we transfer the stuff in the slot under consideration to it
            local freeSlot = turtle.getSelectedSlot()

            turtle.select(position)
            turtle.transferTo(freeSlot)

            -- Now, we try to find the materials that we need. We always try to use the largest stack. 
            -- If we can't find the materials, we quit trying and return false
            if inventory.findLargestItemStack(item) == 0 then
                return false, "Can no longer find required item in inventory: " .. item
            end

            -- But, if we can find the materials, they're now selected, so we put just one item in the slot needed
            turtle.transferTo(position,1)
        end

    end

    -- We now loop through the slots and remove the contents of any slots not in the recipe
    for i = 1, inventory.getNumSlots(), 1 do

        -- We get info about the current slot and see whether it should be empty. If so, we
        -- drop its contents.
        if not recipeTN[i] then
            turtle.select(i)
            turtle.drop()
        end
    end

    --Hopefully things should be in the proper positions now, so we try to craft the thing
    return turtle.craft()

end

-----
-- Computes the amounts of each resource required to craft the recipe provided.
-- @tparam table recipe The recipe whose requirements should be computed (both crafting table notation and
-- turtle inventory notation are acceptable)
-- @treturn table A table whose indices are item identifiers and whose entries are the required quantities
function craft.computeRecipeRequirements(recipe)
    recipeRequirements = {}
    for _, item in pairs(recipe) do
        if not(recipeRequirements[item]) then
            recipeRequirements[item] = 1
        else
            recipeRequirements[item] = recipeRequirements[item] + 1
        end
    end
    return recipeRequirements
end