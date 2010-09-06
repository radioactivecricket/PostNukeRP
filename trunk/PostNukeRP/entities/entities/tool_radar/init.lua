AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.PrecacheModel ("models/props_mining/antlion_detector.mdl")

function ENT:Initialize()	
	self.Entity:SetModel("models/props_mining/antlion_detector.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetHealth( 200 )
	self.Entity:PhysWake()
	self.playbackRate = 0
	self.Ready = 0
	self.SyncTime = 60
	self.entOwner = "none"
	
	local Radar_Sound = Sound("plats/tram_move.wav")
	self.RadarAmb = CreateSound(self.Entity, Radar_Sound )
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() <= 0 then --run on death
		self:SetHealth( 0 )
		umsg.Start("radar_state", rp)
		umsg.String("dead")
		umsg.Short(self.Entity:EntIndex())
		umsg.End()
	end
end 

function ENT:Use( activator, caller )
	if activator:KeyPressed( IN_USE ) then
		if activator:Team() ~= TEAM_WASTELANDER then
			activator:ChatPrint("You don't have any idea how to use this.")
			return
		end
		
		if self.entOwner == "none" then
			self.entOwner = activator:Nick()
		end
		
		local foundGPR = "false"
		local constrs = constraint.FindConstraints( self, "Weld" )
		for k, v in pairs( constrs ) do
			if v.Entity[1].Entity:GetClass() == "tool_gpr" then 
				local ownerGRP = self:GetNWString( "Owner", "None" )
				if ownerGRP ~= self.entOwner then
					constraint.RemoveConstraints( v.Entity[1].Entity, "Weld" )
					foundGPR = "false"
				else
					foundGPR = "true"
				end
			end
		end
		
		local rp = RecipientFilter()
		rp:RemoveAllPlayers()
		rp:AddPlayer( activator )
		
		umsg.Start("radar_menu", rp)
			umsg.Short(self:Health())
			umsg.Short(self.Entity:EntIndex())
			umsg.Entity(self.Entity)
			umsg.String(foundGPR)
			umsg.Short(self.SyncTime)
		umsg.End()
	end
end

function ENT:Think()
	if self.entOwner ~= "none" then
		local owner = self:GetNWString( "Owner", "None" )
		if owner ~= self.entOwner then
			umsg.Start("radar_state", rp)
				umsg.String("none")
				umsg.Short(self.Entity:EntIndex())
			umsg.End()
			self.entOwner = "none"
			self.Ready = 0 
		end
	end
	
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
	
	if self:Health() <= 0 then self.Ready = -1 end
	
	if self.Ready == 1 then
		--self:EmitSound("plats/tram_move.wav", 60, 50 )
		self.Entity:SetPlaybackRate(self.playbackRate)
		self:GetPhysicsObject():EnableMotion(false)
	elseif self.Ready == -1 then
		--self:StopRunningSound()
		self.playbackRate = 0
		self.RadarAmb:Stop()
		self:GetPhysicsObject():EnableMotion(true)
		constraint.RemoveAll(self.Entity)
	else
		self.playbackRate = 0
		self.RadarAmb:Stop()
		self:GetPhysicsObject():EnableMotion(true)
	end
	
	if !self:IsOutside() then
		self.Ready = 0
	end
end

function DoRepair( pl, handler, id, encoded, decoded )
	local ent = decoded[1]
	local amount = 200 - ent:Health()
	
	local State
	if ent:Health() > 0 then
		State = "damaged"
	else
		State = "dead"
	end
	
	pl:Freeze(true)
	pl:ChatPrint("Fixing Radar...")
	
	timer.Simple( amount/10, function ()
		pl:Freeze(false)
		
		ent:SetHealth( 200 )
		
		if ent:Health() > 200 then ent:SetHealth( 200 ) end
		
		pl:ChatPrint("Repair compleate!")
		if State == "dead" then
			umsg.Start("radar_state", pl)
				umsg.String("Standby")
				umsg.Short(ent.Entity:EntIndex())
			umsg.End()
		else
			umsg.Start("radar_state", pl)
				umsg.String("Ready")
				umsg.Short(ent.Entity:EntIndex())
			umsg.End()
		end
		
		ent.Ready = 0
	end )
end
datastream.Hook( "radar_repair_stream", DoRepair )

function DoSync( pl, handler, id, encoded, decoded )
	local ent = decoded[1]

	pl:ChatPrint("Syncing Radar...")
	
	ent:GetPhysicsObject():EnableMotion(false)
	for k, v in pairs( ents.GetAll() ) do
		if v:IsWorld() then
			constraint.Weld(ent.Entity, v, 0, 0, 0, true)
		end
	end
	
	timer.Simple( ent.SyncTime, function ()
		
		pl:ChatPrint("Sync complete!")
		
		umsg.Start("radar_state", pl)
			umsg.String("Ready")
			umsg.Short(ent.Entity:EntIndex())
		umsg.End()
		
		ent.RadarAmb:Play()
		ent.playbackRate = 0.1
		ent.Entity:SetPlaybackRate(ent.playbackRate)
		ent.RadarAmb:ChangePitch( 20 )
		ent.RadarAmb:ChangeVolume( 50 )
		
		local foundGPR = "false"
		local constrs = constraint.FindConstraints( ent, "Weld" )
		for k, v in pairs( constrs ) do
			if v.Entity[1].Entity:GetClass() == "tool_gpr" then 
				local owner = ent:GetNWString( "Owner", "None" )
				if owner ~= ent.entOwner then
					constraint.RemoveConstraints( v.Entity[1].Entity, "Weld" )
					foundGPR = "false"
				else
					foundGPR = "true"
				end
			end
		end
		
		umsg.Start("radar_upgrade", pl)
			umsg.String(foundGPR)
			umsg.Short(ent.Entity:EntIndex())
		umsg.End()
				
		ent.Ready = 1
	end )
end
datastream.Hook( "radar_synching_stream", DoSync )

function DoShutdown( pl, handler, id, encoded, decoded )
	local ent = decoded[1]

	pl:ChatPrint("Radar Shutdown...")
--	ent:StopRunningSound()
	ent.playbackRate = 0
	ent.Ready = 0
	constraint.RemoveAll(ent.Entity)
end
datastream.Hook( "radar_shutdown_stream", DoShutdown )

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
