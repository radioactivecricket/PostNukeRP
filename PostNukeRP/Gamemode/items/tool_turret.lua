local ITEM = {}


ITEM.ID = "tool_turret"

ITEM.Name = "Portable Turret"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 550
ITEM.Small_Parts = 950
ITEM.Chemicals = 175
ITEM.Chance = 100
ITEM.Info = "You'd be lost without your portable turret!  Just $1999.95!"
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "npc_turret_floor"
ITEM.Model = "models/combine_turrets/floor_turret.mdl"
ITEM.Script = ""
ITEM.Weight = 18

function ITEM.ToolCheck( p )
	-- This one returns required items.
	return {["intm_sensorpod"]=1, ["intm_pulsecore"]=1, ["intm_elecboard"]=2, ["intm_servo"]=2}
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,180,0))
	ent:SetPos(pos)
	ent:SetKeyValue( "spawnflags", 0 )
	ent:Spawn()
	ent:Activate()
	--ent:SetNetworkedString("Owner", ply:Nick())
	PNRP.SetOwner(ply, ent)
	
	ent:AddRelationship("npc_floor_turret D_LI 99")
	ent:AddRelationship("npc_chemgrub D_LI 99")
	ent:AddRelationship("player D_LI 99")
	ent:AddRelationship("npc_hdvermin D_LI 99")
	ent:AddRelationship("npc_hdvermin_fast D_LI 99")
	ent:AddRelationship("npc_hdvermin_poison D_LI 99")
	ent:AddRelationship("npc_petbird_crow D_LI 99")
	ent:AddRelationship("npc_petbird_gull D_LI 99")
	ent:AddRelationship("npc_petbird_pigeon D_LI 99")
	
	-- Turned off, so friendly with all.
	ent:AddRelationship("npc_zombie D_LI 99")
	ent:AddRelationship("npc_fastzombie D_LI 99")
	ent:AddRelationship("npc_poisonzombie D_LI 99")
	ent:AddRelationship("npc_antlion D_LI 99")
	ent:AddRelationship("npc_antlionguard D_LI 99")
	ent:AddRelationship("npc_headcrab_poison D_LI 99")
	ent:AddRelationship("npc_headcrab_fast D_LI 99")
	ent:AddRelationship("npc_headcrab D_LI 99")
	
	for k, v in pairs(ents.FindByClass("npc_chemgrub")) do
		ent:AddEntityRelationship(v, D_LI, 99 )
	end
	
	for _, class in pairs(PNRP.friendlies) do
		for k, v in pairs(ents.FindByClass(class)) do
			ent:AddEntityRelationship(v, D_LI, 99 )
		end
	end
	
	-- Important power vars!
	ent.PowerItem = true
	ent.PowerLevel = -50
	ent.Entity:SetNWString("PowerUsage", ent.PowerLevel)	
	ent.NetworkContainer = nil
	ent.LinkedItems = {}
	ent.DirectLinks = {}
	
	-- Turret programming vars
	ent.Whitelist = false
	ent.ProgTable = {}
	
	PNRP.AddWorldCache( ply,ITEM.ID )
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)