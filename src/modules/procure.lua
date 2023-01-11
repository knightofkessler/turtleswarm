-----
-- Library of functions for handling procurement. Contains submodules for implementing procurement behavior for specific items.
--
-- @author Brenden Lecj
-- @author Joshua Fitzgerald

package.path = "/lib/?.lua;" .. package.path
require "utils"
require "inventory"
require "move"
require "action"

-- The library table
procure = {}

-----
-- Responsible for item procurement
-- @tparam string item the item to be procured
-- @tparam int count how much of the item to procure
-- @treturn boolean success or failure
-- @treturn table
function procure.getItem(args)
    local item = args[1]
    local count = args[2]
    if not itemProfiles[item] then
        return false, {["errorMsg"] = "No item profile for item"}
    end
    root = Node:new()
    root:addChild(Node:new(retrieve,{item,count}))

    for i,entry in ipairs(itemProfiles[item]) do
        local procType = assert(entry.procurementType)
        root:addChild(procType)
    end
    return root:runTree()
end

-----
-- Responsible for reaching/making a required utility, like a furnace
-- @tparam string block The block to be reached 
-- @treturn boolean success or failure
-- @treturn table
function procure.goToUtility(block)
    local block = args[1]
    root = Node:new(action.goToUtility,{block})
    root:addChild(Node:new(action.knowsUtilityBlock,{block},CONDITIONAL))
    local placeUtilityBlockNode = root:addChild(Node:new(procure.getItem,{block,1}))
    return root:runTree
end

---The table/submodule for procurementTypes
-- @table procurementTypes
procure.procurementTypes = {}

-----
-- Responsible for crafting
-- @tparam table args The arguments to the function, which should be comprised of
-- The item profile containing this crafting function and the context table for
-- the crafting call
-- @tparam table errorTable The error table
-- @treturn boolean success or failure
-- @treturn table
function procure.procurementTypes.craft(args,errorTable)
    local itemProfile = args[1]
    local contextTable = args[2]
    local recipe = itemProfile.recipe
    local craftCount = contextTable.makeCount
    --itemProfile,context,errorTable
    if errorTable and errorTable.numItemsProcured then
        craftCount = craftCount - errorTable.numItemsProcured
    end
    local root = Mode:new(action.craft,{recipe,craftCount})
    local itemCounts = {}
    for i, item in pairs(recipe) do
        if itemCounts[item] then
            itemCounts[item] = itemCounts[item] + 1
        else
            itemCounts[item] = 0
        end
    end
    for item,count in pairs(itemCounts) do
        root:addChild(procure.getItem,{item,count*craftCount})
    end
    return root:runTree()
end

-----
-- Responsible for smelting
-- @tparam table args The arguments to the function, which should be comprised of
-- The item profile containing this crafting function and the context table for
-- the crafting call
-- @tparam table The context table for the crafting call
-- @tparam table The error table
-- @treturn boolean success or failure
-- @treturn table
function procure.procurementTypes.smelt(itemProfile,context,errorTable)
    local itemProfile = args[1]
    local contextTable = args[2]
    local recipe = itemProfile.recipe
    local smeltCount = contextTable.makeCount
    if errorTable and errorTable.numItemsProcured then
        craftCount = craftCount - errorTable.numItemsProcured
    end
    local root = Node.new(action.smelt,{recipe,smeltCount})
    root:addChild(Node:new(procure.goToUtility,{"minecraft:furnace"}))
    root:addChild(Node:new(procure.getItem,{recipe[1],smeltCount}))

    return root:runTree()

end

---The table/submodule for itemProfiles
-- @table itemProfiles
procure.itemProfiles = {}