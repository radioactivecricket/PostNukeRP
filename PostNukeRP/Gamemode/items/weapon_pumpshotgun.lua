local ITEM = {}
local WEAPON = {}


ITEM.ID = "wep_pumpshotgun"

ITEM.Name = "Pump Shotgun"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 20
ITEM.Small_Parts = 75
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "Uses Shotgun Ammo."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 8
ITEM.Ent = "weapon_pnrp_pumpshotgun"
ITEM.Model = "models/weapons/w_shot_m3super90.mdl"
ITEM.Script = ""
ITEM.Weight = 9

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "buckshot"

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Use( ply )
	local WepName = "weapon_pnrp_pumpshotgun"
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