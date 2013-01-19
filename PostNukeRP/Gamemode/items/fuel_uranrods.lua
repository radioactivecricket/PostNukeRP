local ITEM = {}


ITEM.ID = "fuel_uranrods"

ITEM.Name = "Uranium Fuel Rods"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 5
ITEM.Small_Parts = 0
ITEM.Chemicals = 25
ITEM.Chance = 100
ITEM.Info = "Uranium-235 fuel rods, extremely rare to find today."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "fuel_uranrods"
ITEM.Model = "models/items/crossbowrounds.mdl"
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
		
		ply:AddToInventory("fuel_uran", 60)
		
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


