local ITEM = {}
local WEAPON = {}


ITEM.ID = "wep_shapedcharge"

ITEM.Name = "Shaped Charge"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 10
ITEM.Small_Parts = 5
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = "Uses Shotgun Ammo."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 1
ITEM.Ent = "weapon_pnrp_charge"
ITEM.Model = "models/weapons/w_slam.mdl"
ITEM.Script = ""
ITEM.Weight = 1

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "slam"

function ITEM.Use( ply )
	local WepName = "weapon_pnrp_charge"
	local gotWep = false
	for k, v in pairs(ply:GetWeapons()) do
		if v:GetClass() == WepName then gotWep = true end
	end
	if gotWep == false then 
		ply:Give(WepName) 
		
		return true
	else
		ply:GiveAmmo(1, "slam")
		return true
	end
end


PNRP.AddItem(ITEM)
PNRP.AddWeapon(WEAPON)