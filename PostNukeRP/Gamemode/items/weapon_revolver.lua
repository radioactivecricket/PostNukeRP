local ITEM = {}
local WEAPON = {}

ITEM.ID = "wep_revolver"

ITEM.Name = ".357 Revolver"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 5
ITEM.Small_Parts = 50
ITEM.Chemicals = 20
ITEM.Chance = 100
ITEM.Info = "Uses .357 Ammo."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 6
ITEM.Ent = "weapon_pnrp_revolver"
ITEM.Model = "models/weapons/w_357.mdl"
ITEM.Script = ""
ITEM.Weight = 5

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "357"

function ITEM.Use( ply )
	local WepName = "weapon_real_cs_desert_eagle"
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