-----
-- Library of functions for handling procurement. Contains submodules for implementing procurement behavior for specific items.
--
-- @author Joshua Fitzgerald

package.path = "/lib/?.lua;" .. package.path
require "utils"
require "inventory"
require "move"
require "craft"

-- The library table
procurement = {}

-----
-- Attempts to create 
-- @tparam string item A string containing the identifier of the item to be obtained
function procurement.obtainItemTree(item)

    --General tree-building logic, including finding the relevant procurement type and calling it
    --to build nongeneric parts of the tree, goes here

end

------------------------------------------------------------------------------------------
---                            PROCUREMENT TYPES                                       ---
------------------------------------------------------------------------------------------

---The subtable for procurement type functions
-- @table procurementTypes
procurement.procurementTypes = {}

-----
-- Creates a subtree for procuring ingots
-- @tparam itemProfile the itemProfile for the specific item to be procured
function procurement.procurementTypes.ingot(itemProfile)

    --Tree building logic specific to this procurement type goes here

end

-----
-- Creates a subtree for procuring mined resources
-- @tparam itemProfile the itemProfile for the specific item to be procured
function procurement.procurementTypes.mined(itemProfile)

    --Tree building logic specific to this procurement type goes here

end

-----
-- Creates a subtree for procuring crafted resources
-- @tparam itemProfile the itemProfile for the specific item to be procured
function procurement.procurementTypes.crafted(itemProfile)

    --Tree building logic specific to this procurement type goes here

end

-----
-- Creates a subtree for procuring resources which we don't actively try to get but which 
-- might be useful if we accidentally do (like iron blocks)
-- @tparam itemProfile the itemProfile for the specific item to be procured
function procurement.procurementTypes.incidental(itemProfile)
    -- I don't think we need any extra code here; for incidental items, we'll just want to 
    -- look in the turtle's inventory and any chests, as we would for all other items.
end

------------------------------------------------------------------------------------------
---                            ITEM PROFILES                                           ---
------------------------------------------------------------------------------------------

---The submodule for item profiles
-- @table itemProfiles
procurement.itemProfiles = {}

----------------
---iron stuff---
----------------

procurement.itemProfiles["minecraft:ironIngot"] = {
    ["procurementType"] = procurement.procurementTypes.ingot,
    ["nuggetType"] = "minecraft:iron_nugget",
    ["blockType"] = "minecraft:iron_block",
    ["oreType"] = "minecraft:iron_ore"
}

procurement.itemProfiles["minecraft:iron_nugget"] = {
    ["procurementType"] = procurement.procurementTypes.incidental,
}

procurement.itemProfiles["minecraft:iron_block"] = {
    ["procurementType"] = procurement.procurementTypes.incidental,
}

procurement.itemProfiles["minecraft:iron_ore"] = {
    ["procurementType"] = procurement.procurementTypes.mined,
    ["miningLevel"] = 9
}

----------------
---gold stuff---
----------------

procurement.itemProfiles["minecraft:gold_ingot"] = {
    ["procurementType"] = procurement.procurementTypes.ingot,
    ["nuggetType"] = "minecraft:gold_nugget",
    ["blockType"] = "minecraft:gold_block",
    ["oreType"] = "minecraft:gold_ore"
}

procurement.itemProfiles["minecraft:gold_nugget"] = {
    ["procurementType"] = procurement.procurementTypes.incidental,
}

procurement.itemProfiles["minecraft:gold_block"] = {
    ["procurementType"] = procurement.procurementTypes.incidental,
}

procurement.itemProfiles["minecraft:gold_ore"] = {
    ["procurementType"] = procurement.procurementTypes.mined,
    ["miningLevel"] = 9
}

---------------------
---craftable stuff---
---------------------

procurement.itemProfiles["minecraft:furnace"] = {
    ["procurementType"] = procurement.procurementTypes.crafted,
    ["recipe"] = {"minecraft:cobblestone","minecraft:cobblestone","minecraft:cobblestone",
                  "minecraft:cobblestone",nil,                    "minecraft:cobblestone",
                  "minecraft:cobblestone","minecraft:cobblestone","minecraft:cobblestone"}
}