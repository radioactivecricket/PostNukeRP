local ITEM = {}


ITEM.ID = "intm_pulsecore"

ITEM.Name = "Pulse Core"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 5
ITEM.Small_Parts = 15
ITEM.Chemicals = 20
ITEM.Chance = 100
ITEM.Info = "A plasma weapon pulse core.  It both generates the pulse, and accelerates it."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_pulsecore"
ITEM.Model = "models/props_combine/headcrabcannister01a_skybox.mdl"
ITEM.Script = ""
ITEM.Weight = 1
ITEM.ShopHide = true

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)