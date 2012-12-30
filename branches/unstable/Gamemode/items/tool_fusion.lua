local ITEM = {}


ITEM.ID = "tool_fusion"

ITEM.Name = "Fusion Power Generator"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 500
ITEM.Small_Parts = 425
ITEM.Chemicals = 325
ITEM.Chance = 100
ITEM.Info = "A fusion generator.  Whoop de fuckin' do."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_fusion"
ITEM.Model = "models/props_combine/combine_generator01.mdl"
ITEM.Script = ""
ITEM.Weight = 15

function ITEM.ToolCheck( p )
	-- This one returns required items.
	return {["intm_fusioncore"]=1, ["intm_elecboard"]=5, ["intm_servo"]=2, ["intm_multitool"]=1}
	--return true
end

function ITEM.Create( ply, class, pos )	
	local ent = ents.Create(class)
	ent:SetAngles(ply:GetAngles()+Angle(0,90,0))
	ent:SetPos(pos + Vector(0,0,75))
	ent:Spawn()
	ent:Activate()
	ent:GetPhysicsObject():EnableMotion(false)

	PNRP.SetOwner(ply, ent)
	
	PNRP.AddWorldCache( ply,ITEM.ID )
end


function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)