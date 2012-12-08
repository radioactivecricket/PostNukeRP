local ITEM = {}


ITEM.ID = "tool_gasgen"

ITEM.Name = "Gas Generator"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 250
ITEM.Small_Parts = 175
ITEM.Chemicals = 75
ITEM.Chance = 100
ITEM.Info = "A gas generator.  No worries about global warming anymore."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_gasgen"
ITEM.Model = "models/props_mining/diesel_generator.mdl"
ITEM.Script = ""
ITEM.Weight = 15

function ITEM.ToolCheck( p )
	return {["intm_engine"]=1, ["intm_elecboard"]=2, ["intm_multitool"]=1}
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