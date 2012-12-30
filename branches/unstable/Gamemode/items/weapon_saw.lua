local ITEM = {}
local WEAPON = {}

ITEM.ID = "wep_saw"

ITEM.Name = "SAW Refurb"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 100
ITEM.Small_Parts = 150
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "Uses SMG Ammo."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 100
ITEM.Ent = "weapon_pnrp_saw"
ITEM.Model = "models/weapons/w_mach_m249para.mdl"
ITEM.Script = ""
ITEM.Weight = 16
ITEM.ShopHide = true

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "smg1"

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Use( ply )
	local WepName = "weapon_pnrp_saw"
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

function ITEM.Create( ply, class, pos )
	local ent = ents.Create("ent_weapon")
	--ent:SetNetworkedInt("Ammo", self.Energy)
	ent:SetNWString("WepClass", ITEM.Ent)
	ent:SetModel(ITEM.Model)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	
	return ent
end

PNRP.AddItem(ITEM)
PNRP.AddWeapon(WEAPON)