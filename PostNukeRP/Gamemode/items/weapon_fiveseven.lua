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
ITEM.Weight = 2

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "pistol"

function ITEM.Use( ply )
	local WepName = "weapon_real_cs_five-seven"
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