AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

local schdGrub = ai_schedule.New( "AIBeGrub" )
	schdGrub:EngTask( "TASK_WAIT", 			1 )
	schdGrub:AddTask( "PlaySequence", 				{ Name = "ACT_IDLE", Speed = 1 } )

function ENT:Initialize()
	self:SetModel( "models/antlion_grub.mdl" )
	
 
	self:SetHullType( HULL_TINY );
 
	self:SetSolid( SOLID_BBOX ) 
	self:SetMoveType( MOVETYPE_STEP )
 
	self:CapabilitiesAdd( CAP_MOVE_GROUND )
 
	self:SetMaxYawSpeed( 5000 )
 
	--don't touch stuff above here
	self:SetHealth(50)
	
	self.breedLevel = 0
	timer.Create( "grubupdate_"..tostring(self.Entity:EntIndex()), 60, 0, self.GrubUpdate, self )
	timer.Create( "grubsounds_"..tostring(self.Entity:EntIndex()), 10, 1, self.GrubSound, self )
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
		timer.Destroy( "grubupdate_"..tostring(self.Entity:EntIndex()) )
		timer.Destroy( "grubsounds_"..tostring(self.Entity:EntIndex()) )
		
		local grubGib = ents.Create("prop_ragdoll")
		grubGib:SetModel("models/antlion_grub_squashed.mdl")
		grubGib:SetPos(self:GetPos())
		grubGib:SetAngles(self:GetAngles())
		grubGib:Spawn()
		grubGib:SetSolid(SOLID_VPHYSICS)
		grubGib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		grubGib:Activate()
		
		--Remove Grub from World Cache
		local MyPlayer = NullEntity()
	
		if self:GetNetworkedString("Owner", "none") ~= "World" and self:GetNetworkedString("Owner", "none") ~= "none" then
			for k, v in pairs(player.GetAll()) do
				if v:Nick() == self:GetNetworkedString("Owner", "none") then
					MyPlayer = v
					break
				end
			end
		end
		if MyPlayer ~= NullEntity() then
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
	self:StartSchedule( schdGrub )
end

function ENT.GrubUpdate( ent )
	local nearby_ents = ents.FindInSphere( ent:GetPos(), 125 )
	for k,v in pairs(nearby_ents) do
		if v:IsValid() and v:GetClass() == "npc_chemgrub" and v ~= ent then
			if v:GetNetworkedString("Owner", "none") == ent:GetNetworkedString("Owner", "none") then
				ent.breedLevel = ent.breedLevel + 1
				break
			end
		end
	end
	
	local MyPlayer = NullEntity()
	
	if ent:GetNetworkedString("Owner", "none") ~= "World" and ent:GetNetworkedString("Owner", "none") ~= "none" then
		for k, v in pairs(player.GetAll()) do
			if v:Nick() == ent:GetNetworkedString("Owner", "none") then
				MyPlayer = v
				break
			end
		end
	end
	
	if ent.breedLevel >= 10 and MyPlayer:IsValid() then
		if MyPlayer:Team() == 3 then
			ent.breedLevel = 0
			local yourChance = math.random(100)
			local Retries = 50
			local pos
			
			if yourChance <= (20 + (MyPlayer:GetSkill("Animal Husbandry")*2)) then
				while util.IsInWorld(pos) == false and Retries > 0 do
					pos = ent:GetPos() + Vector(math.random(-75, 75), math.random(-75,75),10)
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
						newGrub:SetNetworkedString("Owner", ent:GetNetworkedString("Owner", "none"))
						
						--Adds new grub to the World Cache
						if MyPlayer ~= NullEntity() then
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
		chemnug_ent:SetPos(ent:LocalToWorld(Vector(30,0,10)))
		chemnug_ent:Spawn()
	end
	
	local soundNum = math.random(3)
	local mysound = Sound("npc/antlion_grub/agrub_stimulated"..tostring(soundNum)..".wav")
	ent:EmitSound( mysound )
end

function ENT.GrubSound( ent )
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
	ent:EmitSound( mysound )
	
	timer.Create( "grubsounds_"..tostring(ent:EntIndex()), newtime, 1, ent.GrubSound, ent )
end

function ENT:OnRemove( )
	timer.Destroy( "grubupdate_"..tostring(self.Entity:EntIndex()) )
	timer.Destroy( "grubsounds_"..tostring(self.Entity:EntIndex()) )
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
