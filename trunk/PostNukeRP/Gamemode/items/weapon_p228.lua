local ITEM = {}
local WEAPON = {}


ITEM.ID = "wep_p228"

ITEM.Name = "Pistol P228"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 2
ITEM.Small_Parts = 25
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = "Uses Pistol Ammo."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 13
ITEM.Ent = "weapon_pnrp_p228"
ITEM.Model = "models/weapons/w_pist_p228.mdl"
ITEM.Script = ""
ITEM.Weight = 2

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "pistol"


function ITEM.Use( ply )
	local WepName = "weapon_pnrp_p228"
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