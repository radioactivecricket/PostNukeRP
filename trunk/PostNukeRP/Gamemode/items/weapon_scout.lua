local ITEM = {}
local WEAPON = {}


ITEM.ID = "wep_scout"

ITEM.Name = "Steyr Scout Sniper"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 50
ITEM.Small_Parts = 100
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "Uses 357 Ammo."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "wep_scout"
ITEM.Model = "models/weapons/w_snip_scout.mdl"
ITEM.Script = ""
ITEM.Weight = 8

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "357"

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)
PNRP.AddWeapon(WEAPON)