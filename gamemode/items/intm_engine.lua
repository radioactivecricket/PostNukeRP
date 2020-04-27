local ITEM = {}


ITEM.ID = "intm_engine"

ITEM.Name = "Old Car Engine"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 50
ITEM.Small_Parts = 75
ITEM.Chemicals = 15
ITEM.Chance = 100
ITEM.Info = "An engine serviced and ready to be installed. (Requires 3 servos)"
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_engine"
ITEM.Model = "models/props_c17/trappropeller_engine.mdl"
ITEM.Script = ""
ITEM.Weight = 5
ITEM.ShopHide = true

function ITEM.ToolCheck( p )
	-- return true
	return {["intm_servo"]=3}
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	
	PNRP.SetOwner(ply, ent)
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)