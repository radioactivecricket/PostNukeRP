local ITEM = {}
local WEAPON = {}


ITEM.ID = "wep_grenade"

ITEM.Name = "Frag Grenade"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 5
ITEM.Small_Parts = 2
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "wep_grenade"
ITEM.Model = "models/weapons/w_grenade.mdl"
ITEM.Script = ""
ITEM.Weight = 1

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "grenade"

function ITEM.Use( ply )
	local WepName = "weapon_frag"
	local gotWep = false
	for k, v in pairs(ply:GetWeapons()) do
		if v:GetClass() == WepName then gotWep = true end
	end
	if gotWep == false then 
		ply:Give(WepName) 
		
		return true
	else
		ply:GiveAmmo(1, "grenade")
		return true
	end
end


PNRP.AddItem(ITEM)
PNRP.AddWeapon(WEAPON)