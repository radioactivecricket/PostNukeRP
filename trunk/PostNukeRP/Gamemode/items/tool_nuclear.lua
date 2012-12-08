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

function ITEM.ToolCheck( p )
	-- This one returns required items.
	return {["intm_nukecore"]=1, ["intm_elecboard"]=5, ["intm_servo"]=2, ["intm_multitool"]=1}
	--return true
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