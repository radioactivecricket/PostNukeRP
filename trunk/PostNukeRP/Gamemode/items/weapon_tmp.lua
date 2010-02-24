local ITEM = {}


ITEM.ID = "wep_tmp"

ITEM.Name = "Steyr TMP"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 20
ITEM.Small_Parts = 75
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "Uses SMG Ammo"
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 30
ITEM.Ent = "wep_tmp"
ITEM.Model = "models/weapons/w_smg_tmp.mdl"
ITEM.Script = ""
ITEM.Weight = 12

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)