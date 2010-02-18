local ITEM = {}


ITEM.ID = "exp_propane_tank"

ITEM.Name = "Explosive Propane Tank"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 12
ITEM.Small_Parts = 0
ITEM.Chemicals = 15
ITEM.Chance = 100
ITEM.Info = "Big Bada Boom!"
ITEM.Type = "junk"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "prop_physics"
ITEM.Model = "models/props_junk/propane_tank001a.mdl"
ITEM.Script = ""
ITEM.Weight = 10

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


