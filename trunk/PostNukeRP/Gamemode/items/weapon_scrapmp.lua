local ITEM = {}
local WEAPON = {}


ITEM.ID = "wep_scrapmp"

ITEM.Name = "Scrap MP"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 20
ITEM.Small_Parts = 75
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "Uses SMG Ammo"
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 40
ITEM.Ent = "weapon_pnrp_scrapmp"
ITEM.Model = "models/weapons/w_smg_mac10.mdl"
ITEM.Script = ""
ITEM.Weight = 5

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "smg1"

function ITEM.Use( ply )
	local WepName = "weapon_pnrp_scrapmp"
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