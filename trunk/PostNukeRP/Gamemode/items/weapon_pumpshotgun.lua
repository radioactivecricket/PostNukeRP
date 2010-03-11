local ITEM = {}
local WEAPON = {}


ITEM.ID = "wep_pumpshotgun"

ITEM.Name = "Pump Shotgun"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 20
ITEM.Small_Parts = 75
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "Uses Shotgun Ammo."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 8
ITEM.Ent = "wep_pumpshotgun"
ITEM.Model = "models/weapons/w_shot_m3super90.mdl"
ITEM.Script = ""
ITEM.Weight = 15

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "buckshot"

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)
PNRP.AddWeapon(WEAPON)