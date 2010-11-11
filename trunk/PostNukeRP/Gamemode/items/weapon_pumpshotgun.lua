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
ITEM.Ent = "weapon_pnrp_pumpshotgun"
ITEM.Model = "models/weapons/w_shot_m3super90.mdl"
ITEM.Script = ""
ITEM.Weight = 9

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "buckshot"

function ITEM.Use( ply )
	local WepName = "weapon_pnrp_pumpshotgun"
	local gotWep = false
	for k, v in pairs(ply:GetWeapons()) do
		if v:GetClass() == WepName then gotWep = true end
	end
	if gotWep == false then 
		ply:Give(WepName) 
		ply:GetWeapon(WepName):SetClip1(0)
		return true
	else
		ply:ChatPrint("Weapon allready equipped.")
		return false
	end
end


PNRP.AddItem(ITEM)
PNRP.AddWeapon(WEAPON)