local ITEM = {}


ITEM.ID = "tool_paper"

ITEM.Name = "Paper"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 0
ITEM.Small_Parts = 0
ITEM.Chemicals =0
ITEM.Chance = 100
ITEM.Info = "The Cheapest guns at the lowest prices!! Made from 87% cardboard and spit!!! Only at..."
ITEM.Type = "misc"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_paper"
ITEM.Model = "models/props_c17/paper01.mdl"
ITEM.Script = ""
ITEM.Weight = 0

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)

	ent:SetAngles( ply:GetAngles()-Angle(0,180,0) )
	ent:SetPos(pos + Vector(0,0,30))
	ent:Spawn()
	ent:Activate()
	
	PNRP.SetOwner(ply, ent)
	ent:SetNetVar("pid", ply.pid)
	ent:SetNetVar("name", ply:Nick().."'s Paper")
	ent:SetNetVar("text", " ")
	ent.name = ent.Entity:GetNetVar("name", "")
	ent.text = ent.Entity:GetNetVar("text", "")
	
	ent:GetPhysicsObject():Wake()
	
--	PNRP.AddWorldCache( ply,ITEM.ID )
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)