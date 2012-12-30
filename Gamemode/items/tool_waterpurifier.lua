local ITEM = {}


ITEM.ID = "tool_waterpurifier"

ITEM.Name = "Water Purifier"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 60
ITEM.Small_Parts = 40
ITEM.Chemicals = 80
ITEM.Chance = 100
ITEM.Info = "Water purifier for making your plants healthier."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_waterpurifier"
ITEM.Model = "models/weapons/hunter_flechette.mdl"
ITEM.Script = ""
ITEM.Weight = 3

function ITEM.ToolCheck( p )
	return {["intm_servo"]=1}
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	--ent:SetNetworkedString("Owner", ply:Nick())
	PNRP.SetOwner(ply, ent)
	
	PNRP.AddWorldCache( ply,ITEM.ID )
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)