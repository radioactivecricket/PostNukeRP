local ITEM = {}


ITEM.ID = "tool_airator"

ITEM.Name = "Automated Airator"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 60
ITEM.Small_Parts = 0
ITEM.Chemicals = 40
ITEM.Chance = 100
ITEM.Info = "Airates the tough wasteland soil for today's plants."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_airator"
ITEM.Model = "models/maxofs2d/light_tubular.mdl"
ITEM.Script = ""
ITEM.Weight = 3

function ITEM.ToolCheck( p )
	return true
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