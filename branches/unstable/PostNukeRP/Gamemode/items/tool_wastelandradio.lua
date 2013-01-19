local ITEM = {}


ITEM.ID = "tool_wastelandradio"

ITEM.Name = "Wasteland Radio"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 20
ITEM.Small_Parts = 2
ITEM.Chemicals =0
ITEM.Chance = 100
ITEM.Info = "A Radio."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_wastelandradio"
ITEM.Model = "models/props_lab/citizenradio.mdl"
ITEM.Script = ""
ITEM.Weight = 1

function ITEM.ToolCheck( p )
	return {["intm_elecboard"]=1}
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)

	ent:SetAngles( ply:GetAngles()-Angle(0,180,0) )
	ent:SetPos(pos + Vector(0,0,0))
	ent:Spawn()
	ent:Activate()
	
	PNRP.SetOwner(ply, ent)
	ent:SetNetworkedString("pid", ply.pid)
	ent:SetNetworkedString("name", ply:Nick().."'s Radio")
	ent.name = ent.Entity:GetNWString("name", "")
	ent.text = ent.Entity:GetNWString("text", "")
	
	ent:GetPhysicsObject():Wake()
	
	PNRP.AddWorldCache( ply,ITEM.ID )
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)