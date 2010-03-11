local ITEM = {}
local WEAPON = {}


ITEM.ID = "wep_m249"

ITEM.Name = "M249 SAW"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 100
ITEM.Small_Parts = 150
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "Uses SMG Ammo."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 200
ITEM.Ent = "wep_m249"
ITEM.Model = "models/weapons/w_mach_m249para.mdl"
ITEM.Script = ""
ITEM.Weight = 20

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "smg1"

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)
PNRP.AddWeapon(WEAPON)