local ITEM = {}


ITEM.ID = "tool_battery"

ITEM.Name = "Battery"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 30
ITEM.Small_Parts = 0
ITEM.Chemicals = 50
ITEM.Chance = 100
ITEM.Info = "A small battery."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_battery"
ITEM.Model = "models/items/car_battery01.mdl"
ITEM.Script = ""
ITEM.Weight = 3
ITEM.SaveState = true

function ITEM.BuildState( ent )
	local PowerLevel = 0
	if( IsValid(ent) ) then 
		PowerLevel = ent.UnitLeft
	end
	
	if PowerLevel == "" or PowerLevel == nil then PowerLevel = 0 end
	
	return "PowerLevel="..PowerLevel
end

function ITEM.ToolCheck( p )
	-- This one returns required items.
	--return {["intm_hudint"]=1, ["intm_elecboard"]=2, ["intm_servo"]=1}
	return true
end

function ITEM.Create( ply, class, pos, iid )	
	local ent = ents.Create(class)
	ent:SetAngles(ply:GetAngles())
	ent:SetPos(pos + Vector(0,0,20))
	ent:Spawn()
	ent:Activate()
	
	if ITEM.SaveState then
		if iid then
			local stateStr = PNRP.ReturnState(iid)
			ent.UnitLeft = tonumber(PNRP.GetFromStat(stateStr, "PowerLevel"))
		else 
			ent.UnitLeft = 0
		end
		
		PNRP.BuildPersistantItem(ply, ent, iid)
	end
	
	if not ent.UnitLeft then ent.UnitLeft = 0 end
	
	PNRP.SetOwner(ply, ent)
	
	PNRP.AddWorldCache( ply,ITEM.ID,ent )
end


function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)