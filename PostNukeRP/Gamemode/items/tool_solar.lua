local ITEM = {}


ITEM.ID = "tool_solar"

ITEM.Name = "Solar Panel"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 150
ITEM.Small_Parts = 50
ITEM.Chemicals = 125
ITEM.Chance = 100
ITEM.Info = "A solar panel.  A loner's best friend."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_solar"
ITEM.Model = "models/hunter/plates/plate1x2.mdl"
ITEM.Script = ""
ITEM.Weight = 15
ITEM.UnBlock = true
ITEM.SaveState = true

function ITEM.BuildState( ent )
	local toolHP = 200
	if( IsValid(ent) ) then toolHP = ent:Health() end
	
	return "HP="..toolHP
end

function ITEM.ToolCheck( p )
	-- This one returns required items.
	return {["intm_solarthinfilm"]=1, ["intm_elecboard"]=1}
	--return true
end

function ITEM.Create( ply, class, pos, iid )	
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	
	if ITEM.SaveState then
		PNRP.BuildPersistantItem(ply, ent, iid)
	end
	
	PNRP.SetOwner(ply, ent)
	
	PNRP.AddWorldCache( ply,ITEM.ID,ent )
end


function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)