AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.PrecacheModel ("models/props_combine/combinethumper002.mdl")

function ENT:Initialize()	
	self.Entity:SetModel("models/props_combine/combinethumper002.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetHealth( 200 )
	self.entOwner = "none"
	self.Entity:PhysWake()
	
	self.Power = 0
	self.entOwner = "none"
	self.playbackRate = 0
	
	self.Entity:NextThink(CurTime() + 1.0)
	self.ToggleTime = CurTime()
	
	local Thumper_Sound = Sound("coast.thumper_ambient")
	self.ThmpAmb = CreateSound(self.Entity, Thumper_Sound )
end

function ENT:ThumperEnable()
	self.Entity:EmitSound("ambient/machines/thumper_startup1.wav", 100, 100)
	self.ThmpAmb:Play()
	local sequence = self.Entity:LookupSequence("idle")
	self.Entity:SetSequence(sequence)
	
	self:GetPhysicsObject():EnableMotion(false)
	for k, v in pairs( ents.GetAll() ) do
		if v:IsWorld() then
			constraint.Weld(self.Entity, v, 0, 0, 0, true)
		end
	end
	
	self.playbackRate = 0.1
	
	self.Entity:SetPlaybackRate(self.playbackRate)
	self.Power = 1
	
	self.repellent = ents.Create("ai_sound")
	self.repellent:SetKeyValue( "soundtype", "256")
	self.repellent:SetKeyValue( "volume", "1000")
	self.repellent:SetKeyValue( "duration", "5")
	self.repellent:SetEntity( "locationproxy", self.Entity)
	self.repellent:SetPos(self.Entity:GetPos())
	self:SetHealth( 200 )
	self.repellent:Spawn()
	
	--self.repellent:Fire("EmitAISound", "", 0)
	self.ToggleTime = CurTime()
	
	local MyPlayer = NullEntity()
	local MySkill = 0
	
	if self.Entity:GetNetworkedString("Owner", "none") ~= "World" and self.Entity:GetNetworkedString("Owner", "none") ~= "none" then
		for k, v in pairs(player.GetAll()) do
			if v:Nick() == self.Entity:GetNetworkedString("Owner", "none") then
				MyPlayer = v
				MySkill = MyPlayer:GetSkill("Mining")
				break
			end
		end
	end
	
	-- The mining code
	timer.Create( "minerupdate_"..tostring(self.Entity:EntIndex()), 60 - (MySkill * 4), 0, function ()
		local resourceChance = math.random(100)
		
		if resourceChance <= 25 then
			local myResource = ents.Create("msc_smallnug")
			myResource:SetModel("models/props_wasteland/gear02.mdl")
			myResource:SetAngles(Angle(0,0,0))
			myResource:SetPos(self.Entity:LocalToWorld(Vector(0,-80+math.random(0,10),math.random(-15,15))))
			myResource:SetKeyValue( "gmod_allowtools", "0" )
			myResource:Spawn()
		else
			local myResource = ents.Create("msc_scrapnug")
			myResource:SetModel("models/gibs/scanner_gib02.mdl")
			myResource:SetAngles(Angle(0,0,0))
			myResource:SetPos(self.Entity:LocalToWorld(Vector(0,-80+math.random(0,10),math.random(-15,15))))
			myResource:SetKeyValue( "gmod_allowtools", "0" )
			myResource:Spawn()
		end
	end)
end

function ENT:ThumperDisable()
	self.Entity:EmitSound("ambient/machines/thumper_shutdown1.wav", 100, 100)
	self.ThmpAmb:Stop()
	self.Power = 0
	--self.Entity:SetPlaybackRate(0.0)
	
	constraint.RemoveAll(self.Entity)
	
	--self.repellent:Remove()
	self.ToggleTime = CurTime()
	
	timer.Destroy( "minerupdate_"..tostring(self.Entity:EntIndex()) )
end

function ENT:Use( activator, caller )
	if activator:KeyPressed( IN_USE ) then
--		if self.Power == 0 then
--			self.Entity:ThumperEnable()
--		elseif self.Power == 1 then
--			self.Entity:ThumperDisable()
--		end
		if activator:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1 then
			if activator:Team() ~= TEAM_SCAVENGER then
				activator:ChatPrint("Admin overide.")
			end
		else
			if activator:Team() ~= TEAM_SCAVENGER then
				activator:ChatPrint("You don't have any idea how to configure this properly.")
				return
			end
		end
				
		if self.entOwner == "none" then
			self.entOwner = activator:Nick()
		end
		
		local rp = RecipientFilter()
		rp:RemoveAllPlayers()
		rp:AddPlayer( activator )
		
		umsg.Start("miner_menu", rp)
		umsg.Short(self:Health())
		umsg.Short(self.Entity:EntIndex())
		umsg.Short(self.Power)
		umsg.Entity(self.Entity)
		umsg.End()
	end
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() <= 0 then --run on death
--		self:Remove()
		self:SetHealth( 0 )
--		umsg.Start("radar_state", rp)
--		umsg.String("dead")
--		umsg.Short(self.Entity:EntIndex())
--		umsg.End()

		self.Entity:ThumperDisable()
	end
end 

function DoOnline( pl, handler, id, encoded, decoded )
	local ent = decoded[1]

	pl:ChatPrint("Initializing Automated Sonic Miner...")
	
	ent.Entity:ThumperEnable()
	
end
datastream.Hook( "miner_online_stream", DoOnline )

function DoOffline( pl, handler, id, encoded, decoded )
	local ent = decoded[1]

	pl:ChatPrint("Shutting Down Automated Sonic Miner...")
	
	ent.Entity:ThumperDisable()
	
end
datastream.Hook( "miner_shutdown_stream", DoOffline )

function DoRepair( pl, handler, id, encoded, decoded )
	local ent = decoded[1]
	local amount = 200 - ent:Health()
	
	pl:Freeze(true)
	pl:ChatPrint("Fixing Unit...")
	
	timer.Simple( amount/10, function ()
		pl:Freeze(false)
		
		ent:SetHealth( 200 )
		
		if ent:Health() > 200 then ent:SetHealth( 200 ) end
		
		pl:ChatPrint("Repair compleate!")
		
	end )
end
datastream.Hook( "miner_repair_stream", DoRepair )

function ENT:Think()
	local myFrame = self.Entity:GetCycle()
	if self:Health() < 150 then
		local effectdata = EffectData()
		local rndGen = math.random(10)
		
		if rndGen == 5 then
			effectdata:SetStart( self:LocalToWorld( Vector( 0, 0, 10 ) ) ) 
			effectdata:SetOrigin( self:LocalToWorld( Vector( 0, 0, 10 ) ) )
			effectdata:SetNormal( Vector(0,0,1) )
			effectdata:SetScale( 0.7 )
			util.Effect( "ManhackSparks", effectdata )
			self:EmitSound("ambient/levels/labs/electric_explosion5.wav", 100, 100 )
		end
	end
	
	if self.Power == 1 then
		self:GetPhysicsObject():EnableMotion(false)
		
		-- if myFrame > 0.95 then
			-- local vOrigin = Vector(0,0,0)
			-- local angposAttach = self.Entity:GetAttachment(self.Entity:LookupAttachment("hammer"))
			-- local effectdata = EffectData()
			-- vOrigin = angposAttach.Pos
			-- effectdata:SetStart( vOrigin )
			-- effectdata:SetOrigin( vOrigin )
			-- effectdata:SetScale( 256 )
			-- util.Effect( "ThumperDust", effectdata)
			
			-- self.Entity:EmitSound("ambient/machines/thumper_dust.wav", 100, 100)
			-- self.Entity:EmitSound("ambient/machines/thumper_hit.wav", 100, 100)
			
			-- self.repellent:Fire("EmitAISound", "", 0)
		-- end

		local sequence = self.Entity:LookupSequence("idle")
		self.Entity:ResetSequence(sequence)
		
		if self.playbackRate < 1 then
			self.playbackRate = (CurTime() - self.ToggleTime) / 10
			self.ThmpAmb:ChangePitch(100*self.playbackRate)
			if self.playbackRate > 1 then
				self.ThmpAmb:ChangePitch(100)
				self.playbackRate = 1
			end
		end
		
		self.Entity:SetPlaybackRate(self.playbackRate)
	elseif self.Power == 0 and self.playbackRate > 0 then
		self.playbackRate = 1 -((CurTime() - self.ToggleTime) / 5)
		if self.playbackRate < 0 then
			self.playbackRate = 0
			self.repellent:Remove()
			if myFrame > 0.95 then
				self.Entity:SetCycle(0)
			end
		end
		self.Entity:SetPlaybackRate(self.playbackRate)
	end
	
	if myFrame > 0.95  and self.playbackRate > 0 then
			local vOrigin = Vector(0,0,0)
			local angposAttach = self.Entity:GetAttachment(self.Entity:LookupAttachment("hammer"))
			local effectdata = EffectData()
			vOrigin = angposAttach.Pos
			effectdata:SetStart( vOrigin )
			effectdata:SetOrigin( vOrigin )
			effectdata:SetScale( 256 )
			util.Effect( "ThumperDust", effectdata)
			
			self.Entity:EmitSound("ambient/machines/thumper_dust.wav", 100, 100)
			self.Entity:EmitSound("ambient/machines/thumper_hit.wav", 100, 100)
			
			self.repellent:Fire("EmitAISound", "", 0)
		end
	
	self.Entity:NextThink(CurTime() + 0.1)
	return true
end

function ENT:OnRemove()
	self.ThmpAmb:Stop()
	self.Entity:StopSound("ambient/machines/thumper_dust.wav")
	self.Entity:StopSound("ambient/machines/thumper_hit.wav")
	self.repellent:Remove()
	timer.Destroy( "minerupdate_"..tostring(self.Entity:EntIndex()) )
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
