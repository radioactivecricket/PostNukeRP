local ITEM = {}


ITEM.ID = "tool_workbench"

ITEM.Name = "Workbench"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 100
ITEM.Small_Parts = 150
ITEM.Chemicals = 70
ITEM.Chance = 100
ITEM.Info = "A workbench with different tools for better items."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_workbench"
ITEM.Model = "models/props_canal/winch02.mdl"
ITEM.Script = ""
ITEM.Weight = 15

function ITEM.ToolCheck( p )
	return {["intm_diamsaw"]=1, ["intm_elecboard"]=1, ["intm_servo"]=2}
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