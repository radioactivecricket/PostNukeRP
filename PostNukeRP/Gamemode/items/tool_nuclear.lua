local ITEM = {}


ITEM.ID = "tool_nuclear"

ITEM.Name = "Nuclear Power Generator"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 375
ITEM.Small_Parts = 300
ITEM.Chemicals = 200
ITEM.Chance = 100
ITEM.Info = "A nuclear generator.  All hail the Atom!"
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_nuclear"
ITEM.Model = "models/props_lab/cornerunit2.mdl"
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
	-- This one returns required items.
	return {["intm_nukecore"]=1, ["intm_elecboard"]=5, ["intm_servo"]=2, ["intm_multitool"]=1}
	--return true
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
	
	PNRP.AddWorldCache( ply,ITEM.ID,ent )
end


function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)