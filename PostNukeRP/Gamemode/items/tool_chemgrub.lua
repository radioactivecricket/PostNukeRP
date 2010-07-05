local ITEM = {}


ITEM.ID = "tool_chemgrub"

ITEM.Name = "Wasteland Worm"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 100
ITEM.Small_Parts = 100
ITEM.Chemicals = 350
ITEM.Chance = 100
ITEM.Info = "Long poly-carbonate chained excretions and fluorescent reactions!  Dream come true!"
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "npc_chemgrub"
ITEM.Model = "models/antlion_grub.mdl"
ITEM.Script = ""
ITEM.Weight = 4

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	ent:SetNetworkedString("Owner", ply:Nick())
	
	ent:AddRelationship("npc_floor_turret D_LI 99")
	ent:AddRelationship("npc_chemgrub D_LI 99")
	ent:AddRelationship("player D_LI 99")
	PNRP.AddWorldCache( ply,ITEM.ID )
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)