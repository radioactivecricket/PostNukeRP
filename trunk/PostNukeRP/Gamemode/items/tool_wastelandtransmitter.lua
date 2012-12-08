local ITEM = {}


ITEM.ID = "tool_wastelandtransmitter"

ITEM.Name = "Wasteland FM Transmitter"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 200
ITEM.Small_Parts = 100
ITEM.Chemicals =10
ITEM.Chance = 100
ITEM.Info = "FM Transmiter."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_wastelandtransmitter"
ITEM.Model = "models/props_lab/workspace003.mdl"
ITEM.Script = ""
ITEM.Weight = 10

function ITEM.ToolCheck( p )
	return {["intm_sensorpod"]=1, ["intm_elecboard"]=5}
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)

	ent:SetAngles( ply:GetAngles()-Angle(0,180,0) )
	ent:SetPos(pos + Vector(0,0,20))
	ent:Spawn()
	ent:Activate()
	
	PNRP.SetOwner(ply, ent)
	ent:SetNetworkedString("pid", ply.pid)
	ent:SetNetworkedString("name", ply:Nick().."'s Transmitter")
	ent.name = ent.Entity:GetNWString("name", "")
	
	ent:GetPhysicsObject():Wake()
	
	PNRP.AddWorldCache( ply,ITEM.ID )
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)