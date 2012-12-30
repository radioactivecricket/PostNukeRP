local ITEM = {}


ITEM.ID = "tool_paper"

ITEM.Name = "Paper"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 0
ITEM.Small_Parts = 0
ITEM.Chemicals =0
ITEM.Chance = 100
ITEM.Info = "A vending machine to sell items."
ITEM.Type = "tool"
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
	ent:SetNetworkedString("pid", ply.pid)
	ent:SetNetworkedString("name", ply:Nick().."'s Paper")
	ent:SetNetworkedString("text", " ")
	ent.name = ent.Entity:GetNWString("name", "")
	ent.text = ent.Entity:GetNWString("text", "")
	
	ent:GetPhysicsObject():Wake()
	
--	PNRP.AddWorldCache( ply,ITEM.ID )
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)