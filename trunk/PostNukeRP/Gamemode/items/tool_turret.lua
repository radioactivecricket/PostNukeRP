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

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,180,0))
	ent:SetPos(pos)
	ent:SetKeyValue( "spawnflags", 0 )
	ent:Spawn()
	ent:Activate()
	ent:SetNetworkedString("Owner", ply:Nick())
	
	ent:AddRelationship("npc_floor_turret D_LI 99")
	ent:AddRelationship("player D_LI 99")
end

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)