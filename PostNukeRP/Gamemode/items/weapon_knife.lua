local ITEM = {}
local WEAPON = {}

ITEM.ID = "wep_knife"
ITEM.Name = "Knife"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 30
ITEM.Small_Parts = 5
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = "Wow! A crummy knife you built."
ITEM.Type = "weapon"
ITEM.Remove = true
ITEM.Energy = 15
ITEM.Ent = "weapon_pnrp_knife"
ITEM.Model = "models/weapons/w_knife_t.mdl"
ITEM.Script = ""
ITEM.Weight = 10
ITEM.ShopHide = false

WEAPON.ID = ITEM.ID
WEAPON.AmmoType = "none"

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Use( ply )
	local WepName = "weapon_pnrp_knife"
	local gotWep = false
	for k, v in pairs(ply:GetWeapons()) do
		if v:GetClass() == WepName then gotWep = true end
	end
	if gotWep == false then 
		ply:Give(WepName)
		return true
	else
		ply:ChatPrint("Weapon already equipped.")
		return false
	end
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create("ent_weapon")
	--ent:SetNetworkedInt("Ammo", self.Energy)
	ent:SetNetVar("WepClass", ITEM.Ent)
	ent:SetModel(ITEM.Model)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	
	return ent
end

PNRP.AddItem(ITEM)
PNRP.AddWeapon(WEAPON)