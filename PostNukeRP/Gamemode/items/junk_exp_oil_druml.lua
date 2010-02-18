local ITEM = {}


ITEM.ID = "exp_oil_drum"

ITEM.Name = "Explosive Oil Drum"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 15
ITEM.Small_Parts = 0
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "Big Bada Boom!"
ITEM.Type = "junk"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "prop_physics"
ITEM.Model = "models/props_c17/oildrum001_explosive.mdl"
ITEM.Script = ""
ITEM.Weight = 20

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


