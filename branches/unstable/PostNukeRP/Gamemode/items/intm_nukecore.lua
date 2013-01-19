local ITEM = {}


ITEM.ID = "intm_nukecore"

ITEM.Name = "Nuclear Reactor Core"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 40
ITEM.Small_Parts = 20
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = "A rare, heavy part.  It's the reaction chamber for a small nuclear reactor."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_nukecore"
ITEM.Model = "models/combine_helicopter/helicopter_bomb01.mdl"
ITEM.Script = ""
ITEM.Weight = 5
ITEM.ShopHide = true

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)