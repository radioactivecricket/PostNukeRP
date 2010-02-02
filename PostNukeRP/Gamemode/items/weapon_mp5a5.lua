local ITEM = {}


ITEM.ID = "wep_mp5a5"

ITEM.Name = "HK MP-5A5"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 20
ITEM.Small_Parts = 75
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "Uses SMG Ammo"
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "wep_mp5a5"
ITEM.Model = "models/weapons/w_smg_mp5.mdl"
ITEM.Script = ""
ITEM.Weight = 10

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)