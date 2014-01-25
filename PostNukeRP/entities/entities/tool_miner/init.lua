AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.AddNetworkString("miner_online_stream")
util.AddNetworkString("miner_shutdown_stream")
util.AddNetworkString("miner_repair_stream")

util.PrecacheModel ("models/props_combine/combinethumper002.mdl")

function ENT:Initialize()	
	self.Entity:SetModel("models/props_combine/combinethumper002.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetHealth( 200 )
	self.entOwner = "none"
	self.moveActive = true
	self.Entity:PhysWake()
	
	self.Power = 0
	self.entOwner = "none"
	self.playbackRate = 0
	
	-- Important power vars!
	self.PowerItem = true
	self.PowerLevel = 0
	self.NetworkContainer = nil
	self.LinkedItems = {}
	self.DirectLinks = {}
	
	self.Entity:NextThink(CurTime() + 1.0)
	self.ToggleTime = CurTime()
	
	local Thumper_Sound = Sound("coast.thumper_ambient")
	self.ThmpAmb = CreateSound(self.Entity, Thumper_Sound )
	
	self.PowerUsage = -100
	self.Entity:SetNWString("PowerUsage", self.PowerUsage)
end

function ENT:ThumperEnable()
	self.Entity:EmitSound("ambient/machines/thumper_startup1.wav", 100, 100)
	self.ThmpAmb:Play()
	local sequence = self.Entity:LookupSequence("idle")
	self.Entity:SetSequence(sequence)
	
	self.PowerLevel = self.PowerUsage
	if IsValid(self.NetworkContainer) then
		self.NetworkContainer:UpdatePower()
	end
	
	--Keeps miner from beeing moved.
	self:GetPhysicsObject():EnableMotion(false)
	self.moveActive = false
--	for k, v in pairs( ents.GetAll() ) do
--		if v:IsWorld() then
--			constraint.Weld(self.Entity, v, 0, 0, 0, true)
--		end
--	end
	
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
	
	local MyPlayer = nil
	local MySkill = 0
	
	if self.Entity:GetNetworkedString("Owner", "none") ~= "World" and self.Entity:GetNetworkedString("Owner", "none") ~= "none" then
		MyPlayer = self.Entity:GetNetworkedString("ownerent", nil)
		MySkill = MyPlayer:GetSkill("Mining")
		-- for k, v in pairs(player.GetAll()) do
			-- if v:GetNetworkedString( "UID" , "none" ) == self.Entity:GetNetworkedString("Owner_UID", "none") then
				-- MyPlayer = v
				-- MySkill = MyPlayer:GetSkill("Mining")
				-- break
			-- end
		-- end
	end
	
	-- The mining code
	timer.Create( "minerupdate_"..tostring(self.Entity:EntIndex()), 60 - (MySkill * 4), 0, function ()
		local resourceChance = math.random(100)
		
		if resourceChance <= 25 then
			local myResource = ents.Create("msc_smallnug")
			myResource:SetModel("models/props_wasteland/gear02.mdl")
			myResource:SetAngles(Angle(0,0,0))
			myResource:SetPos(self.Entity:LocalToWorld(Vector(math.random(-10,20),-80+math.random(0,15),math.random(10,15))))
			myResource:SetKeyValue( "gmod_allowtools", "0" )
			myResource:Spawn()
		else
			local myResource = ents.Create("msc_scrapnug")
			myResource:SetModel("models/gibs/scanner_gib02.mdl")
			myResource:SetAngles(Angle(0,0,0))
			myResource:SetPos(self.Entity:LocalToWorld(Vector(math.random(-10,20),-80+math.random(0,15),math.random(10,15))))
			myResource:SetKeyValue( "gmod_allowtools", "0" )
			myResource:Spawn()
		end
	end)
end

function ENT:ThumperDisable()
	self.Entity:EmitSound("ambient/machines/thumper_shutdown1.wav", 100, 100)
	self.ThmpAmb:Stop()
	self.Power = 0
	self.moveActive = true
	--self.Entity:SetPlaybackRate(0.0)
	
	self.PowerLevel = 0
	if IsValid(self.NetworkContainer) then
		self.NetworkContainer:UpdatePower()
	end
	--constraint.RemoveAll(self.Entity)
	
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
		if activator:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then
			if activator:Team() ~= TEAM_SCAVENGER then
				activator:ChatPrint("Admin override.")
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
		
		net.Start("miner_menu")
			net.WriteDouble(self:Health())
			net.WriteDouble(self.Entity:EntIndex())
			net.WriteDouble(self.Power)
			net.WriteEntity(self.Entity)
		net.Send(activator)
	end
end
util.AddNetworkString("miner_menu")

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() <= 0 then --run on death
--		self:Remove()
		self:SetHealth( 0 )

		self.Entity:ThumperDisable()
	end
end 

function DoOnline( )
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	--local ent = decoded[1]

	ply:ChatPrint("Initializing Automated Sonic Miner...")
	
	ent.Entity:ThumperEnable()
	
end
--datastream.Hook( "miner_online_stream", DoOnline )
net.Receive( "miner_online_stream", DoOnline )

function DoOffline( )
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	--local ent = decoded[1]

	ply:ChatPrint("Deactivating Automated Sonic Miner...")
	
	ent.Entity:ThumperDisable()
	
end
--datastream.Hook( "miner_shutdown_stream", DoOffline )
net.Receive( "miner_shutdown_stream", DoOffline )

function DoRepair( )
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	--local ent = decoded[1]
	local amount = 200 - ent:Health()
	
	ply:Freeze(true)
	ply:ChatPrint("Repairing Unit...")
	
	timer.Simple( amount/10, function ()
		ply:Freeze(false)
		
		ent:SetHealth( 200 )
		
		if ent:Health() > 200 then ent:SetHealth( 200 ) end
		
		ply:ChatPrint("Repair complete!")
		
	end )
end
--datastream.Hook( "miner_repair_stream", DoRepair )
net.Receive( "miner_repair_stream", DoRepair )

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
			self.ThmpAmb:ChangePitch(100*self.playbackRate, 0)
			if self.playbackRate > 1 then
				self.ThmpAmb:ChangePitch(100, 0)
				self.playbackRate = 1
			end
		end
		
		self.Entity:SetPlaybackRate(self.playbackRate)
		
		if (not self.NetworkContainer) or (not self.NetworkContainer.NetPower) or self.NetworkContainer.NetPower < 0 then
			self:ThumperDisable()
		end
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
	if self.repellent then
		if self.repellent:IsValid() then
			self.repellent:Remove()
		end
	end
	self:PowerUnLink()
	timer.Destroy( "minerupdate_"..tostring(self.Entity:EntIndex()) )
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
