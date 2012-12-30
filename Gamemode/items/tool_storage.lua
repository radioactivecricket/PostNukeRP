local ITEM = {}


ITEM.ID = "tool_storage"

ITEM.Name = "Player Storage Container"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 250
ITEM.Small_Parts = 10
ITEM.Chemicals = 25
ITEM.Chance = 100
ITEM.Info = "For Player Personal Storage."
ITEM.Type = "tool"
ITEM.Remove = false
ITEM.Energy = 0
ITEM.Ent = "tool_storage"
ITEM.Model = "models/props_c17/Lockers001a.mdl"
ITEM.Script = ""
ITEM.Weight = 1
ITEM.Capacity = 500
ITEM.ProfileCost = "500 150 100"

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetModel("models/props_c17/Lockers001a.mdl")
				  
	ent:SetAngles( ply:GetAngles()-Angle(0,180,0) )
	ent:SetPos(pos + Vector(0,0,20))
	ent:Spawn()
	ent:Activate()
	
	PNRP.SetOwner(ply, ent)
	ent:SetNetworkedString("pid", ply.pid)
	ent:SetNetworkedString("name", ply:Nick().."'s Storage")
	ent:SetNetworkedString("storageid", nil)
	
	ent:GetPhysicsObject():Wake()
	
	PNRP.AddWorldCache( ply,ITEM.ID )
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)