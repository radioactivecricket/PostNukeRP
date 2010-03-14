local ITEM = {}
local WEAPON = {}


ITEM.ID = "wep_grenade"

ITEM.Name = "Frag Grenade"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 5
ITEM.Small_Parts = 2
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 1
ITEM.Ent = "wep_grenade"
ITEM.Model = "models/weapons/w_grenade.mdl"
ITEM.Script = ""
ITEM.Weight = 3

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "grenade"

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)
PNRP.AddWeapon(WEAPON)