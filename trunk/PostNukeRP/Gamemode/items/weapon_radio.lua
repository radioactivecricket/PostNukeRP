local ITEM = {}
local WEAPON = {}

ITEM.ID = "wep_radio"

ITEM.Name = "Home-made Radio"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 10
ITEM.Small_Parts = 50
ITEM.Chemicals = 20
ITEM.Chance = 100
ITEM.Info = "A radio to talk to others!"
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "weapon_radio"
ITEM.Model = "models/props_citizen_tech/transponder.mdl"
ITEM.Script = ""
ITEM.Weight = 4

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "none"

function ITEM.Use( ply )
	local WepName = "weapon_radio"
	local gotWep = false
	for k, v in pairs(ply:GetWeapons()) do
		if v:GetClass() == WepName then gotWep = true end
	end
	if gotWep == false then 
		ply:Give(WepName) 
		-- ply:GetWeapon(WepName):SetClip1(0)
		return true
	else
		ply:ChatPrint("Weapon allready equipped.")
		return false
	end
end


PNRP.AddItem(ITEM)
PNRP.AddWeapon(WEAPON)