local ITEM = {}
local WEAPON = {}


ITEM.ID = "wep_shotgun"

ITEM.Name = "Shotgun"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 20
ITEM.Small_Parts = 75
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "Uses Shotgun Ammo."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 6
ITEM.Ent = "wep_shotgun"
ITEM.Model = "models/weapons/w_shot_xm1014.mdl"
ITEM.Script = ""
ITEM.Weight = 10

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "buckshot"

function ITEM.Use( ply )
	local WepName = "weapon_real_cs_xm1014"
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