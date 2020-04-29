local ITEM = {}


ITEM.ID = "fuel_h2pod"

ITEM.Name = "Deuterium Fuel Pod"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 2
ITEM.Small_Parts = 0
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "A fuel pod filled with an H-2 isotope, or Deuterium."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "fuel_h2pod"
ITEM.Model = "models/items/combine_rifle_ammo01.mdl"
ITEM.Script = ""
ITEM.Weight = 6
ITEM.ShopHide = true

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Use( ply )
	local actWeight = PNRP.InventoryWeight( ply )
	local actCapacity
	if team.GetName(ply:Team()) == "Scavenger" then
		actCapacity = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		actCapacity = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	if actCapacity >= actWeight + 6 then
		local sound = Sound("items/ammo_pickup.wav")
		self.Entity:EmitSound( sound )
		
		ply:AddToInventory("fuel_h2", 60)
		
		return true
	else
		ply:ChatPrint("You cannot carry the contents of the fuel pod!")
		return false
	end
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
end

PNRP.AddItem(ITEM)


