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
ITEM.SaveState = true

function ITEM.BuildState( ent )
	local toolHP = 200
	local FuelLevel = 0
	if( IsValid(ent) ) then 
		toolHP = ent:Health() 
		FuelLevel = ent.FuelLevel
	end
	
	if FuelLevel == "" or FuelLevel == nil then FuelLevel = 0 end
	return "HP="..toolHP..",FuelLevel="..FuelLevel
end

function ITEM.ToolCheck( p )
	return {["intm_engine"]=1, ["intm_elecboard"]=2, ["intm_multitool"]=1}
end

function ITEM.Create( ply, class, pos, iid )	
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	
	if ITEM.SaveState then
		if iid then
			local stateStr = PNRP.ReturnState(iid)
			ent.FuelLevel = tonumber(PNRP.GetFromStat(stateStr, "FuelLevel"))
		end
		
		PNRP.BuildPersistantItem(ply, ent, iid)
	end
	
	PNRP.SetOwner(ply, ent)
	
	PNRP.AddWorldCache( ply,ITEM.ID )
end


function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)