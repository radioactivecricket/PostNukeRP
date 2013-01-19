local ITEM = {}


ITEM.ID = "intm_multitool"

ITEM.Name = "Electronic Multitool"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 15
ITEM.Small_Parts = 30
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = "A robotic multitool."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_multitool"
ITEM.Model = "models/gibs/shield_scanner_gib4.mdl"
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