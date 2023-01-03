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
-- @tparam table recipe The recipe to craft, provided in crafting table notation
-- @treturn bool Whether crafting succeeded
function procurement.obtainItemTree(item)

end


---The subtable for procurement type functions
-- @table procurementTypes
procurement.procurementTypes = {}

-----
-- Creates a subtree for procuring ingots
-- @tparam itemProfile the itemProfile for the specific item to be procured
function procurement.procurementTypes.ingot(itemProfile)

end

-----
-- Creates a subtree for procuring mined resources
-- @tparam itemProfile the itemProfile for the specific item to be procured
function procurement.procurementTypes.mined(itemProfile)

end

-----
-- Creates a subtree for procuring crafted resources
-- @tparam itemProfile the itemProfile for the specific item to be procured
function procurement.procurementTypes.crafted(itemProfile)

end

---The subtable for item profiles
-- @table itemProfiles
procurement.itemProfiles = {}

---An item profile for iron ingots
-- @table itemProfiles.ironIngot
procurement.itemProfiles.ironIngot = {
    ["procurementType"] = procurement.procurementTypes.ingot,
    ["nuggetType"] = "minecraft:iron_nugget",
    ["blockType"] = "minecraft:iron_block",
    ["oreType"] = "minecraft:iron_ore"
}

---An item profile for iron ore
-- @table itemProfiles.ironOre
procurement.itemProfiles.ironOre = {
    ["procurementType"] = procurement.procurementTypes.mined,
    ["miningLevel"] = 9
}

---An item profile for gold ingots
-- @table itemProfiles.goldIngot
procurement.itemProfiles.goldIngot = {
    ["procurementType"] = procurement.procurementTypes.ingot,
    ["nuggetType"] = "minecraft:gold_nugget",
    ["blockType"] = "minecraft:gold_block",
    ["oreType"] = "minecraft:gold_ore"
}

---An item profile for gold ore
-- @table itemProfiles.goldOre
procurement.itemProfiles.goldOre = {
    ["procurementType"] = procurement.procurementTypes.mined,
    ["miningLevel"] = 9
}

---An item profile for a furnace
-- @table itemProfiles.furnace
procurement.itemProfiles.furnace = {
    ["procurementType"] = procurement.procurementTypes.crafted,
    ["recipe"] = {"minecraft:cobblestone","minecraft:cobblestone","minecraft:cobblestone",
                  "minecraft:cobblestone",nil,                    "minecraft:cobblestone",
                  "minecraft:cobblestone","minecraft:cobblestone","minecraft:cobblestone"}
}