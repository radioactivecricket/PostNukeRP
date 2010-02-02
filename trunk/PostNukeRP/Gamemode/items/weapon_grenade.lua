local ITEM = {}


ITEM.ID = "wep_grenade"

ITEM.Name = "Frag Grenade"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 10
ITEM.Small_Parts = 2
ITEM.Chemicals = 20
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "wep_grenade"
ITEM.Model = "models/weapons/w_grenade.mdl"
ITEM.Script = ""
ITEM.Weight = 3

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)