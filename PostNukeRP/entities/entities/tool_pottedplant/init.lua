AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/props/cs_office/plant01.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props/cs_office/plant01.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:PhysWake()
	
	self.FruitLevel = 0
	self.PlantStatus = 60
	self.Filtered = false
	self.Fertilized = false
	self.Airator = false
	self.CanPrune = true
	self.LastUser = NullEntity()
	timer.Create( "plantupdate_"..tostring(self.Entity:EntIndex()), 120, 0, PlantUpdate, self.Entity )
end

function PlantUpdate( ent )
	local statusChange = -10
	
	if ent.PlantStatus > 75 and ent.FruitLevel < 3 then
		-- ent.FruitLevel = ent.FruitLevel + 1
		local fruitent = ents.Create("food_orange")
		fruitent:SetModel("models/props/cs_italy/orange.mdl")
		fruitent:SetAngles(Angle(0,0,0))
		fruitent:SetPos(ent:LocalToWorld(Vector(0,0,20)))
		fruitent:Spawn()
	end
	
	local MySkill = 0
	
	if ent.LastUser:IsValid() and ent.LastUser:Team() == TEAM_CULTIVATOR then
		MySkill = ent.LastUser:GetSkill("Farming")
	end
	
	if MySkill > 0 then statusChange = statusChange + MySkill end
	
	if ent.Filtered then
		statusChange = statusChange + 4
	end
	
	if ent.Fertilized then
		statusChange = statusChange + 3
	end
	
	if ent.Airator then
		statusChange = statusChange + 3
	end
	
	ent.PlantStatus = ent.PlantStatus + statusChange
	if ent.PlantStatus < 0 then ent.PlantStatus = 0 end
	if ent.PlantStatus > 100 then ent.PlantStatus = 100 end
end

function DoFilter( pl, handler, id, encoded, decoded )
	local ent = decoded[1]
	
	if pl:GetResource( "Small_Parts" ) < 20 then
		pl:ChatPrint( "Not enough small parts to upgrade!" )
		return
	end
	
	pl:Freeze(true)
	pl:ChatPrint("Building filtered water drip...")
	
	timer.Simple( 10, function ()
		pl:Freeze(false)
		pl:DecResource( "Small_Parts", 20 )
		
		ent.Filtered = true
		pl:ChatPrint("It's been built!")
	end )
end
datastream.Hook( "addfilter_stream", DoFilter )

function DoFertilize( pl, handler, id, encoded, decoded )
	local ent = decoded[1]
	
	if pl:GetResource( "Chemicals" ) < 5 then
		pl:ChatPrint( "Not enough chemicals to fertilize!" )
		return
	end
	
	pl:Freeze(true)
	pl:ChatPrint("Fertilizing...")
	
	timer.Simple( 5, function ()
		pl:Freeze(false)
		pl:DecResource( "Chemicals", 5 )
		
		ent.Fertilized = true
		timer.Create( "unfertilize_"..tostring(ent:EntIndex()), 600, 1, function()
			ent.Fertilized = false
		end )
		pl:ChatPrint("Fertilized!")
	end )
end
datastream.Hook( "fertilize_stream", DoFertilize )

function DoAirator( pl, handler, id, encoded, decoded )
	local ent = decoded[1]
	
	if pl:GetResource( "Small_Parts" ) < 20 then
		pl:ChatPrint( "Not enough small parts to upgrade!" )
		return
	end
	
	pl:Freeze(true)
	pl:ChatPrint("Building automatic airator...")
	
	timer.Simple( 10, function ()
		pl:Freeze(false)
		pl:DecResource( "Small_Parts", 20 )
		
		ent.Airator = true
		pl:ChatPrint("It's been built!")
	end )
end
datastream.Hook( "addairator_stream", DoAirator )

function DoHarvest( pl, handler, id, encoded, decoded )
	local ent = decoded[1]
	local spawnPos = ent:GetPos() + Vector( 0, 0, 10 )
	
	pl:Freeze(true)
	pl:ChatPrint("Harvesting...")
	timer.Simple( 5, function ()
		ent:EmitSound(Sound("items/ammo_pickup.wav"))
		pl:AddToInventory( "food_orange" )
		pl:ChatPrint("An orange is now in your inventory!")
		
		ent.FruitLevel = ent.FruitLevel - 1
		pl:Freeze(false)
	end )
end
datastream.Hook( "harvest_stream", DoHarvest )
	
function DoPrune( pl, handler, id, encoded, decoded )
	local ent = decoded[1]
	local amount = decoded[2]
	ent.CanPrune = false
	pl:Freeze(true)
	pl:ChatPrint("Pruning...")
	
	timer.Simple( amount/2, function ()
		pl:Freeze(false)
		ent.CanPrune = true
		
		ent.PlantStatus = ent.PlantStatus + amount
		if ent.PlantStatus > 100 then ent.PlantStatus = 100 end
		pl:ChatPrint("It looks much better!")
	end )
end
datastream.Hook( "prune_stream", DoPrune )

function ENT:OnRemove()
	timer.Destroy( "plantupdate_"..tostring(self.Entity:EntIndex()) )
end

function ENT:Use( activator, caller )
	if activator:KeyPressed( IN_USE ) then
		if activator:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1 then
			if activator:Team() ~= TEAM_CULTIVATOR then
				activator:ChatPrint("Admin overide.")
			end
		else
			if activator:Team() ~= TEAM_CULTIVATOR then
				activator:ChatPrint("You don't have any idea how to take care of this plant.")
				return
			end
		end
		
		self.LastUser = activator
		
		local rp = RecipientFilter()
		rp:RemoveAllPlayers()
		rp:AddPlayer( activator )
		 
		umsg.Start("plant_menu", rp)
			umsg.Short(self.FruitLevel)
			umsg.Short(self.PlantStatus)
			umsg.Bool(self.Filtered)
			umsg.Bool(self.Fertilized)
			umsg.Bool(self.Airator)
			umsg.Bool(self.CanPrune)
			umsg.Entity(self.Entity)
		umsg.End()
	end
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
