local ITEM = {}
local WEAPON = {}


ITEM.ID = "wep_fiveseven"

ITEM.Name = "Pistol Five-Seven"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 2
ITEM.Small_Parts = 25
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = "Uses Pistol Ammo."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 20
ITEM.Ent = "wep_fiveseven"
ITEM.Model = "models/weapons/w_pist_fiveseven.mdl"
ITEM.Script = ""
ITEM.Weight = 5

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "pistol"

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)
PNRP.AddWeapon(WEAPON)