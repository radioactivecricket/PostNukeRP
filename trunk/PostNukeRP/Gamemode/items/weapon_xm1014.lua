local ITEM = {}


ITEM.ID = "wep_shotgun"

ITEM.Name = "Shotgun"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 20
ITEM.Small_Parts = 75
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "Uses Shotgun Ammo."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 6
ITEM.Ent = "wep_shotgun"
ITEM.Model = "models/weapons/w_shot_xm1014.mdl"
ITEM.Script = ""
ITEM.Weight = 15

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)