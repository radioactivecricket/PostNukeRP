local ITEM = {}


ITEM.ID = "tool_cnc"

ITEM.Name = "CNC Mill"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 125
ITEM.Small_Parts = 200
ITEM.Chemicals = 100
ITEM.Chance = 100
ITEM.Info = "A workbench with different tools for better items."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_cnc"
ITEM.Model = "models/props_lab/reciever_cart.mdl"
ITEM.Script = ""
ITEM.Weight = 15

function ITEM.ToolCheck( p )
	return {["intm_waterjet"]=1, ["intm_multitool"]=1, ["intm_elecboard"]=2, ["intm_servo"]=4}
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos+Vector(0,0,20))
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