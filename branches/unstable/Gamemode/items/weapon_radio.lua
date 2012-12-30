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

function ITEM.ToolCheck( p )
	-- This one returns required items.
	return {["intm_hudint"]=1, ["intm_elecboard"]=1}
end

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