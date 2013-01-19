AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.AddNetworkString("grubFeed")

-- local schdGrub = ai_schedule.New( "AIBeGrub" )
	-- schdGrub:EngTask( "TASK_WAIT", 			1 )
	-- schdGrub:AddTask( "PlaySequence", 				{ Name = "ACT_IDLE", Speed = 1 } )

function ENT:Initialize()
	self:SetModel( "models/antlion_grub.mdl" )
	--self:SetModel( "models/antlion.mdl" )
 
	self:SetHullType( HULL_TINY );
 
	self:SetSolid( SOLID_BBOX ) 
	self:SetMoveType( MOVETYPE_STEP )
 
	self:CapabilitiesAdd( CAP_MOVE_GROUND )
 
	self:SetMaxYawSpeed( 5000 )
 
	--don't touch stuff above here
	self:SetHealth(50)
	
	self.FoodLevel = 0
	
	self.breedLevel = 0
	timer.Create( "grubupdate_"..tostring(self), 60, 0, function ()
		self:GrubUpdate()
	end)
	timer.Create( "grubsounds_"..tostring(self), 10, 1, function ()
		self:GrubSound()
	end)
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() <= 0 then --run on death
		--npc/antlion_grub/squashed.wav
		local mysound = Sound("npc/antlion_grub/squashed.wav")
		self:EmitSound( mysound )
		--self:Remove()
		self:SetNoDraw(true)
		self:SetSolid(SOLID_NONE)
		--self:SetSchedule( SCHED_FALL_TO_GROUND ) --because it's given a new schedule, the old one will end.
		timer.Destroy( "grubupdate_"..tostring(self) )
		timer.Destroy( "grubsounds_"..tostring(self) )
		
		local grubGib = ents.Create("prop_ragdoll")
		grubGib:SetModel("models/antlion_grub_squashed.mdl")
		grubGib:SetPos(self:GetPos())
		grubGib:SetAngles(self:GetAngles())
		grubGib:Spawn()
		grubGib:SetSolid(SOLID_VPHYSICS)
		grubGib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		grubGib:Activate()
		
		--Remove Grub from World Cache
		local MyPlayer = nil
	
		if self:GetNetworkedString("Owner", "none") ~= "World" and self:GetNetworkedString("Owner", "none") ~= "none" then
			for k, v in pairs(player.GetAll()) do
				if v:Nick() == self:GetNetworkedString("Owner", "none") then
					MyPlayer = v
					break
				end
			end
		end
		if MyPlayer ~= nil then
			ItemID = PNRP.FindItemID( self:GetClass() )
			if ItemID then
				PNRP.TakeFromWorldCache( MyPlayer, ItemID )
			end
		end
		
		timer.Simple(10, function ()
			grubGib:Remove()
		end )
		
		self:Remove()
	end
end 

function ENT:SelectSchedule()
	-- self:StartSchedule( schdGrub )
	self:SetSchedule(SCHED_IDLE_STAND)
end

function ENT:GrubUpdate()
	local MyPlayer = self:GetNWEntity( "ownerent", nil )
	
	if self.mother and MyPlayer:IsValid() and self.FoodLevel >= 5 and self.partner.FoodLevel >= 5 then
		self.breedLevel = self.breedLevel + 1
	end
	
	if self.breedLevel >= 10 and MyPlayer:IsValid() then
		if MyPlayer:Team() == TEAM_SCIENCE then
			self.breedLevel = 0
			self.FoodLevel = 0
			self.partner.FoodLevel = 0
			local yourChance = math.random(100)
			local Retries = 50
			local pos
			
			if yourChance <= (25 + (MyPlayer:GetSkill("Animal Husbandry")*5)) then
				while util.IsInWorld(pos) == false and Retries > 0 do
					pos = self:GetPos() + Vector(math.random(-75, 75), math.random(-75,75),10)
					Retries = Retries - 1
				end
				
				if Retries > 0 then
					--Find ground
					local trace = {}
					trace.start = pos
					trace.endpos = trace.start + Vector(0,0,-100000)
					trace.mask = MASK_SOLID_BRUSHONLY

					local groundtrace = util.TraceLine(trace)
					
					--Find sky
					local trace = {}
					trace.start = groundtrace.HitPos
					trace.endpos = trace.start + Vector(0,0,100000)

					local skytrace = util.TraceLine(trace)

					--Find water?
					local trace = {}
					trace.start = groundtrace.HitPos
					trace.endpos = trace.start + Vector(0,0,1)
					trace.mask = MASK_WATER

					local watertrace = util.TraceLine(trace)
					
					if !watertrace.Hit then
						local newGrub = ents.Create("npc_chemgrub")
						newGrub:SetPos(groundtrace.HitPos+Vector(0,0,20))
						newGrub:Spawn()
						newGrub:Activate()
						PNRP.SetOwner(MyPlayer, newGrub)
						
						--Adds new grub to the World Cache
						if MyPlayer ~= nil then
							ItemID = PNRP.FindItemID( newGrub:GetClass() )
							if ItemID then
								PNRP.AddWorldCache( MyPlayer,ItemID )
							end
						end
					end
				end
			end
		end
	end

	--local howMany = math.random(3)
	local howMany = 1
	
	for i = 1, howMany do
		local chemnug_ent = ents.Create( "msc_chemnug" )
		chemnug_ent:SetModel("models/grub_nugget_medium.mdl")
		chemnug_ent:SetAngles(Angle(0,0,0))
		chemnug_ent:SetPos(self:LocalToWorld(Vector(30+math.random(0,10),math.random(-5,5),10)))
		chemnug_ent:Spawn()
	end
	
	local soundNum = math.random(3)
	local mysound = Sound("npc/antlion_grub/agrub_stimulated"..tostring(soundNum)..".wav")
	self:EmitSound( mysound )
end

function ENT:GrubSound( )
	local newtime = math.random(6,30)
	local soundType = math.random(2)
	local soundNum = 0
	local mysound
	
	if soundType == 1 then
		--idle sounds
		soundNum = math.random(4)
		
		if soundNum == 1 then
			mysound = Sound("npc/antlion_grub/agrub_idle1.wav")
		elseif soundNum == 2 then
			mysound = Sound("npc/antlion_grub/agrub_idle3.wav")
		elseif soundNum == 3 then
			mysound = Sound("npc/antlion_grub/agrub_idle6.wav")
		elseif soundNum == 4 then
			mysound = Sound("npc/antlion_grub/agrub_idle8.wav")
		end
	elseif soundType == 2 then
		soundNum = math.random(3)
		
		mysound = Sound("npc/antlion_grub/agrub_alert"..tostring(soundNum)..".wav")
	end
	self:EmitSound( mysound )
	
	timer.Create( "grubsounds_"..tostring(self), newtime, 1, function ()
		self:GrubSound()
	end)
end

function ENT:OnRemove( )
	timer.Destroy( "grubupdate_"..tostring(self) )
	timer.Destroy( "grubsounds_"..tostring(self) )
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end

function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and IsValid(activator) and activator:IsPlayer() then
		if activator:KeyPressed( IN_USE ) then
			if IsValid(self:GetNWEntity( "ownerent", nil )) and self:GetNWEntity( "ownerent", nil ) == activator then
				if activator:Team() == TEAM_SCIENCE then
					if IsValid(activator.grubSelect) and self.Entity ~= activator.grubSelect then
						if IsValid(self.partner) then
							activator:ChatPrint("This grub already has a breeding partner.")
						else
							self.partner = activator.grubSelect
							self.partner.partner = self.Entity
							self.mother = true
							self.partner.mother = nil
							
							activator:ChatPrint("These grubs have now been paired for breeding!")
						end
						
						activator.grubSelect = nil
						return
					else
						activator.grubSelect = nil
					end
					
					if not self.partner then self.partner = nil end
					
					local actInv = PNRP.Inventory( activator )
					local availFood = actInv["fuel_grubfood"]
					
					net.Start("grub_menu")
						net.WriteEntity(self.Entity)
						net.WriteEntity(self.partner)
						net.WriteDouble(availFood or 0)
						net.WriteDouble(self.FoodLevel)
					net.Send(activator)
				else
					activator:ChatPrint("You can't mess with this grub!  You don't know what to do!")
				end
			else
				activator:ChatPrint("You can't mess with this grub!  It's not yours!")
			end
		end
	end
end
util.AddNetworkString("grub_menu")

function GrubSelect()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	ply.grubSelect = ent
	if IsValid(ent.partner) then
		ent.partner.mother = nil
		ent.partner.partner = nil
	end
	ent.mother = nil
	ent.partner = nil
	ply:ChatPrint("This grub has been selected!")
end
net.Receive( "grubSelect", GrubSelect )

function GrubFeed()
	local amnt = net.ReadDouble()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	local plyInv = PNRP.Inventory( ply )
	local avail = plyInv["fuel_grubfood"]
	
	if amnt == nil then amnt = 0 end
	if amnt > 5 - ent.FoodLevel then amnt = 5 - ent.FoodLevel end
	if avail == nil then avail = 0 end
	if amnt > avail then
		ply:ChatPrint("You don't have that much food.")
		return
	end
	
	ent.FoodLevel = ent.FoodLevel + amnt
	PNRP.TakeFromInventoryBulk(ply, "fuel_grubfood", amnt)
	
	ply:ChatPrint("You fed your grub "..tostring(amnt).." nuggets of food.")
end
net.Receive( "grubFeed", GrubFeed )
