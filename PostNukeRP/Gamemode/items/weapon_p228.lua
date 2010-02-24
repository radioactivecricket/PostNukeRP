local ITEM = {}


ITEM.ID = "wep_p228"

ITEM.Name = "Pistol P228"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 2
ITEM.Small_Parts = 25
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = "Uses Pistol Ammo."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 12
ITEM.Ent = "wep_p228"
ITEM.Model = "models/weapons/w_pist_p228.mdl"
ITEM.Script = ""
ITEM.Weight = 5

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)