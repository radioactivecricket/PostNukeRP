local ITEM = {}


ITEM.ID = "tool_ladder"

ITEM.Name = "Ladder"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 140
ITEM.Small_Parts =0
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = "Your general purpose ladder."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_ladder"
ITEM.Model = "models/props_c17/metalladder001.mdl"
ITEM.Script = ""
ITEM.Weight = 6

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(ply:GetAngles()-Angle(0,180,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	
	PNRP.SetOwner(ply, ent)
	
	PNRP.AddWorldCache( ply,ITEM.ID )
end


function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)