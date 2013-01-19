AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/props_wasteland/antlionhill.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props_wasteland/antlionhill.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:PhysWake()
	
	self.AntList = {}
	self.GuardList = {}
	self.MaxAnts = GetConVarNumber("pnrp_MaxMoundAntlions")
	self.MaxGuards = GetConVarNumber("pnrp_MaxMoundGuards")
	self.SquadSize = GetConVarNumber("pnrp_MoundAntlionsPerCycle")
	self.SpawnRate = math.Round(GetConVarNumber("pnrp_MoundMobRate") * 60)
	self.GuardChance = GetConVarNumber("pnrp_MoundGuardChance")
	self.MyPos = self:GetPos()
	self.BelowZ = 400
	self.ZAmount = self.BelowZ / 50
	self.Alive = true
	self.NextPlay = CurTime()
	self.dieSound = CreateSound(self, Sound("ambient/machines/wall_crash1.wav"))
	self.PlayDeath = 0
	self.AlertStatus = 0
	self.LastAlert = 0
	self.eggs = math.random(1,2)
	
	timer.Create( "moundspawn_"..tostring(self), 0.1, 0, function()
		self:MoundSpawn()
	end)
	timer.Create( "mounddefense_"..tostring(self), 5, 0, function()
		self:MoundDefense()
	end)
	timer.Create( "moundupdate_"..tostring(self), self.SpawnRate, 0, function()
		self:MoundUpdate()
	end)
	
	self.Entity:SetMaxHealth( 6000 )
	self.Entity:SetHealth( 6000 )
end

function ENT:MoundDefense()
	for k, v in pairs(self.AntList) do
		if not v:IsValid() then
			table.remove(self.AntList, k)
		end
	end
	for k, v in pairs(self.GuardList) do
		if not v:IsValid() then
			table.remove(self.GuardList, k)
		end
	end
	
	if not self.Alive then return end
	
	local nearbyEnts = ents.FindInSphere( self:GetPos() + Vector(0,0,50), 750 )
	
	for _, v in pairs(nearbyEnts) do
		if v:IsValid() then
			if (v:GetClass() == "npc_zombie" or v:GetClass() == "npc_fastzombie" or v:GetClass() == "npc_poisonzombie" or v:IsPlayer()) and self.AlertStatus == 0 then
				self.AlertStatus = 1
				self.LastAlert = CurTime()
				for _, ant in pairs( self.AntList ) do
					if ant:IsValid() then
						--ant:SetNPCState( NPC_STATE_ALERT )
						--ant:NavSetGoal( v:GetPos() )
						ant:SetLastPosition(v:GetPos())
						--ant:SetEnemy( v )
						ant:SetSchedule( SCHED_FORCED_GO_RUN )
					end
				end
				for _, guard in pairs( self.GuardList ) do
					if guard:IsValid() then
						--guard:SetNPCState( NPC_STATE_ALERT )
						--guard:NavSetGoal( v:GetPos() )
						guard:SetLastPosition(v:GetPos())
						--guard:SetEnemy( v )
						guard:SetSchedule( SCHED_FORCED_GO_RUN )
					end
				end
			end
		end
	end
	
	local timeSinceLast = CurTime() - self.LastAlert
	
	if timeSinceLast > 60 and self.AlertStatus then
		self.AlertStatus = 0
		for _, ant in pairs( self.AntList ) do
			if ant:IsValid() then
				--ant:SetNPCState( NPC_STATE_ALERT )
				ant:SetSchedule( SCHED_IDLE_WANDER )
			end
		end
		for _, guard in pairs( self.GuardList ) do
			if guard:IsValid() then
				--guard:SetNPCState( NPC_STATE_ALERT )
				guard:SetSchedule( SCHED_IDLE_WANDER )
			end
		end
	end
end

function ENT:MoundSpawn()
	self:SetPos(self.MyPos - Vector(0,0,self.BelowZ))
	
	self.BelowZ = self.BelowZ - self.ZAmount
	if self.BelowZ <= 0 then
		self.BelowZ = 0
		self:SetPos( self.MyPos )
		timer.Destroy("moundspawn_"..tostring(self))
	end
end

function ENT:MoundDestroy()
	self:SetPos(self.MyPos - Vector(0,0,self.BelowZ))
	
	self.BelowZ = self.BelowZ + self.ZAmount
	if self.BelowZ >= self.ZAmount * 50 then
		self.BelowZ = self.ZAmount * 50
		self:Remove()
		timer.Destroy( "mounddestroy_"..tostring(self) )
	end
end

function ENT:Think()
	if self:Health() <= 0 and self.PlayDeath == 0 then
	--if self.Alive == false and self.dieSound:IsPlaying( ) == false then 
		--self.dieSound:Play()
		self:EmitSound("ambient/machines/wall_crash1.wav", 100, 70 )
		self.PlayDeath = 1
		return 
	end
	if not self.Alive then return end
	if CurTime() > self.NextPlay then
		local soundList = { "ambient/levels/coast/antlion_hill_ambient1.wav",
						"ambient/levels/coast/antlion_hill_ambient2.wav",
						"ambient/levels/coast/antlion_hill_ambient4.wav",
						"ambient/levels/prison/inside_battle_antlion1.wav",
						"ambient/levels/prison/inside_battle_antlion2.wav",
						"ambient/levels/prison/inside_battle_antlion3.wav",
						"ambient/levels/prison/inside_battle_antlion4.wav",
						"ambient/levels/prison/inside_battle_antlion5.wav",
						"ambient/levels/prison/inside_battle_antlion6.wav",
						"ambient/levels/prison/inside_battle_antlion7.wav",
						"ambient/levels/prison/inside_battle_antlion8.wav"}
	
		local mySound = soundList[math.random(1, #soundList)]
		
		self.Entity:EmitSound( mySound, 400, 100 )
		self.NextPlay = CurTime() + SoundDuration(mySound) + math.random(0,5)
	end
end

function ENT:MoundUpdate()
	self.MaxAnts = GetConVarNumber("pnrp_MaxMoundAntlions")
	self.MaxGuards = GetConVarNumber("pnrp_MaxMoundGuards")
	self.SpawnRate = math.Round(GetConVarNumber("pnrp_MoundMobRate") * 60)
	self.GuardChance = GetConVarNumber("pnrp_MoundGuardChance")
	
	local myAnts = self.AntList
	local myGuards = self.GuardList
	
	for k, v in pairs(self.AntList) do
		if not v:IsValid() then
			table.remove(self.AntList, k)
		end
	end
	for k, v in pairs(self.GuardList) do
		if not v:IsValid() then
			table.remove(self.GuardList, k)
		end
	end
	
	if #myAnts >= self.MaxAnts and #myGuards >= self.MaxGuards then return end
	local randomized = math.random(1,100)
	if randomized <= self.GuardChance and #myGuards < self.MaxGuards then
		local spawnPos
		local clearFromMound = false
		
		repeat
			spawnPos = self:GetPos() + Vector(  math.random(-150,150), math.random(-150,150), 200 )
			
			local trace = {}
			trace.start = spawnPos
			trace.endpos = trace.start + Vector(0, 0, -1000)

			local clearTrace = util.TraceLine(trace)
			if clearTrace.Entity and clearTrace.Entity:GetClass() ~= "pnrp_antmound" then
				clearFromMound = true
				spawnPos = clearTrace.HitPos
			end
		until clearFromMound
		
		local guard = ents.Create("npc_antlionguard")
		guard:SetPos(spawnPos+Vector(0,0,400))
		guard:SetKeyValue ("squadname", "npc_antlions_"..self.Entity:EntIndex())
		
		guard:Spawn()
		guard:SetNetworkedString("Owner", "Unownable")
		
		table.insert(self.GuardList, guard)
		return
	end
	
	if #myAnts >= self.MaxAnts then return end
	local spawnSize = self.SquadSize
	if self.SquadSize > self.MaxAnts - #myAnts then
		spawnSize = self.MaxAnts - #myAnts
	end
	
	for i=1, spawnSize do
		local spawnPos
		local clearFromMound = false
		
		repeat
			spawnPos = self:GetPos() + Vector(  math.random(-150,150), math.random(-150,150), 400 )
			
			local trace = {}
			trace.start = spawnPos
			trace.endpos = trace.start + Vector(0, 0, -1000)

			local clearTrace = util.TraceLine(trace)
			if clearTrace.Entity and clearTrace.Entity:GetClass() ~= "pnrp_antmound" then
				clearFromMound = true
				spawnPos = clearTrace.HitPos
			end
		until clearFromMound
		
		local antlion = ents.Create("npc_antlion")
		antlion:SetPos(spawnPos+Vector(0,0,400))
		antlion:SetKeyValue ("squadname", "npc_antlions_"..self.Entity:EntIndex())
		
		antlion:Spawn()
		antlion:SetNetworkedString("Owner", "Unownable")
		
		table.insert(self.AntList, antlion)
	end
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() <= 0 and self.Alive then --run on death
		self.Alive = false
		timer.Destroy( "moundsounds_"..tostring(self.Entity) )
		timer.Create( "mounddestroy_"..tostring(self.Entity), 0.1, 0, function ()
			self:MoundDestroy()
		end )
		
		local killer = dmg:GetAttacker()
		if killer:IsPlayer() then
			killer:IncXP(100)
		end
		
		local Ants = self.AntList
		local Guards = self.GuardList
		timer.Simple(20, function ()
			for _, ant in pairs(Ants) do
				if ant then
					if ant:IsValid() then
						ant:Remove()
					end
				end
			end
			for _, guard in pairs(Guards) do
				if guard then
					if guard:IsValid() then
						guard:Remove()
					end
				end
			end
		end)
	end
end

function ENT:OnRemove()
	self.dieSound:Stop()
	timer.Destroy( "moundupdate_"..tostring(self) )
	timer.Destroy( "mounddefense_"..tostring(self) )
	timer.Destroy( "mounddestroy_"..tostring(self) )
end

function ENT:Use( activator, caller )
	if not activator:KeyPressed( IN_USE ) then return end
	if activator:Team() ~= TEAM_WASTELANDER then return end
	
	if activator.scavving == self then
		timer.Destroy(activator:UniqueID().."_mound_"..tostring(self))
		timer.Destroy(activator:UniqueID().."_mound_"..tostring(self).."_end")
		
		activator:SetMoveType(MOVETYPE_WALK)
		activator.scavving = nil
		net.Start("stopProgressBar")
		net.Send(activator)
		return
	elseif activator.scavving then
		return end
	
	if self.eggs <= 0 then return end
	
	activator:SelectWeapon("gmod_rp_hands")
	activator:SetMoveType(MOVETYPE_NONE)
	activator.scavving = self
	
	activator:EmitSound(Sound("ambient/levels/streetwar/building_rubble"..tostring(math.random(1,5))..".wav"))
	
	net.Start("startProgressBar")
		net.WriteDouble(30)
	net.Send(activator)
	
	local mound = self
	timer.Create( activator:UniqueID().."_mound_"..tostring(self), 0.25, 120, function()
			activator:SelectWeapon("gmod_rp_hands")
			if (not mound:IsValid()) or (not activator:Alive()) then
				activator:SetMoveType(MOVETYPE_WALK)
				net.Start("stopProgressBar")
				net.Send(activator)
				activator.scavving = nil
				if mound:IsValid() then 
					timer.Stop(activator:UniqueID().."_mound_"..tostring(mound:EntIndex()))
				end
				return
			end
		end )
	
	local myself = self
	timer.Create( activator:UniqueID().."_mound_"..tostring(self).."_end", 30, 1, function() 
			net.Start("stopProgressBar")
			net.Send(activator)
			-- ply:Freeze(false)
			activator:SetMoveType(MOVETYPE_WALK)
			activator.scavving = nil
			
			if mound and IsValid(mound) and activator and IsValid(activator) and activator:IsPlayer() and mound.eggs > 0 then
				if math.random(1,100) <= 33 then
					PNRP.Items["intm_grubegg"].Create(activator, PNRP.Items["intm_grubegg"].Ent, activator:GetShootPos() + activator:GetForward() * 30 )
					mound.eggs = mound.eggs - 1
				end
			end
		end )
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
