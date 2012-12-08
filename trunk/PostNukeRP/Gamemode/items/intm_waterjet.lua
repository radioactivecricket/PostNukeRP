local ITEM = {}


ITEM.ID = "intm_waterjet"

ITEM.Name = "Waterjet Cutter"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 10
ITEM.Small_Parts = 20
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = "A surviving waterjet cutter from ages past.  It cuts metal precisely with high pressure water."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_waterjet"
ITEM.Model = "models/gibs/manhack_gib02.mdl"
ITEM.Script = ""
ITEM.Weight = 1
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