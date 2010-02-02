local ITEM = {}


ITEM.ID = "coke"

ITEM.Name = "Can of coke"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 2
ITEM.Small_Parts = 0
ITEM.Chemicals = 2
ITEM.Chance = 100
ITEM.Info = "Food system not empimented yet."
ITEM.Type = "food"
ITEM.Remove = true
ITEM.Energy = 18
ITEM.Ent = "prop_physics"
ITEM.Model = "models/props_junk/popcan01a.mdl"
ITEM.Script = ""
ITEM.Weight = 1

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


