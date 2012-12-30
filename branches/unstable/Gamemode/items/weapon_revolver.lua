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

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Use( ply )
	local WepName = "weapon_pnrp_revolver"
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