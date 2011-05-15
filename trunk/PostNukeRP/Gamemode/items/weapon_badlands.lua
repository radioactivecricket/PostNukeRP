local ITEM = {}
local WEAPON = {}


ITEM.ID = "wep_badlands"

ITEM.Name = "Badlands Rifle"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 40
ITEM.Small_Parts = 90
ITEM.Chemicals = 35
ITEM.Chance = 100
ITEM.Info = "Uses 357 Ammo."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 15
ITEM.Ent = "weapon_pnrp_badlands"
ITEM.Model = "models/weapons/w_rif_galil.mdl"
ITEM.Script = ""
ITEM.Weight = 10

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "357"

function ITEM.Use( ply )
	local WepName = "weapon_pnrp_badlands"
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