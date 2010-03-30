local ITEM = {}
local WEAPON = {}


ITEM.ID = "wep_ump45"

ITEM.Name = "HK UMP-45"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 20
ITEM.Small_Parts = 75
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "Uses SMG Ammo"
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 25
ITEM.Ent = "wep_ump45"
ITEM.Model = "models/weapons/w_smg_ump45.mdl"
ITEM.Script = ""
ITEM.Weight = 5

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "smg1"

function ITEM.Use( ply )
	local WepName = "weapon_real_cs_ump_45"
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