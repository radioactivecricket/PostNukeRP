local ITEM = {}
local WEAPON = {}

ITEM.ID = "wep_deagle"

ITEM.Name = "Desert Eagle"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 5
ITEM.Small_Parts = 50
ITEM.Chemicals = 20
ITEM.Chance = 100
ITEM.Info = "Uses .357 Ammo."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 7
ITEM.Ent = "wep_deagle"
ITEM.Model = "models/weapons/w_pist_deagle.mdl"
ITEM.Script = ""
ITEM.Weight = 7

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