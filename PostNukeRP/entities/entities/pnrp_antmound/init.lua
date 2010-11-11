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
	
	timer.Create( "moundspawn_"..tostring(self.Entity:EntIndex()), 0.1, 0, self.MoundSpawn, self )
	timer.Create( "mounddefense_"..tostring(self.Entity:EntIndex()), 5, 0, self.MoundDefense, self )
	timer.Create( "moundupdate_"..tostring(self.Entity:EntIndex()), self.SpawnRate, 0, self.MoundUpdate, self )
	
	self.Entity:SetMaxHealth( 3000 )
	self.Entity:SetHealth( 3000 )
end

function ENT.MoundDefense( ent )
	for k, v in pairs(ent.AntList) do
		if not v:IsValid() then
			table.remove(ent.AntList, k)
		end
	end
	for k, v in pairs(ent.GuardList) do
		if not v:IsValid() then
			table.remove(ent.GuardList, k)
		end
	end
	
	if not ent.Alive then return end
	
	local nearbyEnts = ents.FindInSphere( ent:GetPos() + Vector(0,0,50), 750 )
	
	for _, v in pairs(nearbyEnts) do
		if v:IsValid() then
			if (v:GetClass() == "npc_zombie" or v:GetClass() == "npc_fastzombie" or v:GetClass() == "npc_poisonzombie" or v:IsPlayer()) and ent.AlertStatus == 0 then
				ent.AlertStatus = 1
				ent.LastAlert = CurTime()
				for _, ant in pairs( ent.AntList ) do
					if ant:IsValid() then
						--ant:SetNPCState( NPC_STATE_ALERT )
						--ant:NavSetGoal( v:GetPos() )
						ant:SetLastPosition(v:GetPos())
						--ant:SetEnemy( v )
						ant:SetSchedule( SCHED_FORCED_GO_RUN )
					end
				end
				for _, guard in pairs( ent.GuardList ) do
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
	
	local timeSinceLast = CurTime() - ent.LastAlert
	
	if timeSinceLast > 60 and ent.AlertStatus then
		ent.AlertStatus = 0
		for _, ant in pairs( ent.AntList ) do
			if ant:IsValid() then
				--ant:SetNPCState( NPC_STATE_ALERT )
				ant:SetSchedule( SCHED_IDLE_WANDER )
			end
		end
		for _, guard in pairs( ent.GuardList ) do
			if guard:IsValid() then
				--guard:SetNPCState( NPC_STATE_ALERT )
				guard:SetSchedule( SCHED_IDLE_WANDER )
			end
		end
	end
end

function ENT.MoundSpawn( ent )
	ent:SetPos(ent.MyPos - Vector(0,0,ent.BelowZ))
	
	ent.BelowZ = ent.BelowZ - ent.ZAmount
	if ent.BelowZ <= 0 then
		ent.BelowZ = 0
		ent:SetPos( ent.MyPos )
		timer.Destroy("moundspawn_"..tostring(ent:EntIndex()))
	end
end

function ENT.MoundDestroy( ent )
	ent:SetPos(ent.MyPos - Vector(0,0,ent.BelowZ))
	
	ent.BelowZ = ent.BelowZ + ent.ZAmount
	if ent.BelowZ >= ent.ZAmount * 50 then
		ent.BelowZ = ent.ZAmount * 50
		ent:Remove()
		timer.Destroy( "mounddestroy_"..tostring(ent:EntIndex()) )
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

function ENT.MoundUpdate( ent )
	ent.MaxAnts = GetConVarNumber("pnrp_MaxMoundAntlions")
	ent.MaxGuards = GetConVarNumber("pnrp_MaxMoundGuards")
	ent.SpawnRate = math.Round(GetConVarNumber("pnrp_MoundMobRate") * 60)
	ent.GuardChance = GetConVarNumber("pnrp_MoundGuardChance")
	
	local myAnts = ent.AntList
	local myGuards = ent.GuardList
	
	for k, v in pairs(ent.AntList) do
		if not v:IsValid() then
			table.remove(ent.AntList, k)
		end
	end
	for k, v in pairs(ent.GuardList) do
		if not v:IsValid() then
			table.remove(ent.GuardList, k)
		end
	end
	
	if #myAnts >= ent.MaxAnts and #myGuards >= ent.MaxGuards then return end
	local randomized = math.random(1,100)
	if randomized <= ent.GuardChance and #myGuards < ent.MaxGuards then
		local spawnPos
		local clearFromMound = false
		
		repeat
			spawnPos = ent:GetPos() + Vector(  math.random(-150,150), math.random(-150,150), 200 )
			
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
		guard:SetKeyValue ("squadname", "npc_antlions_"..ent.Entity:EntIndex())
		
		guard:Spawn()
		guard:SetNetworkedString("Owner", "Unownable")
		
		table.insert(ent.GuardList, guard)
		return
	end
	
	if #myAnts >= ent.MaxAnts then return end
	local spawnSize = ent.SquadSize
	if ent.SquadSize > ent.MaxAnts - #myAnts then
		spawnSize = ent.MaxAnts - #myAnts
	end
	
	for i=1, spawnSize do
		local spawnPos
		local clearFromMound = false
		
		repeat
			spawnPos = ent:GetPos() + Vector(  math.random(-150,150), math.random(-150,150), 400 )
			
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
		antlion:SetKeyValue ("squadname", "npc_antlions_"..ent.Entity:EntIndex())
		
		antlion:Spawn()
		antlion:SetNetworkedString("Owner", "Unownable")
		
		table.insert(ent.AntList, antlion)
	end
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() <= 0 and self.Alive then --run on death
		self.Alive = false
		timer.Destroy( "moundsounds_"..tostring(self.Entity:EntIndex()) )
		timer.Create( "mounddestroy_"..tostring(self.Entity:EntIndex()), 0.1, 0, self.MoundDestroy, self )
		
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
	timer.Destroy( "moundupdate_"..tostring(self.Entity:EntIndex()) )
	timer.Destroy( "mounddefense_"..tostring(self.Entity:EntIndex()) )
	timer.Destroy( "mounddestroy_"..tostring(self.Entity:EntIndex()))
end

-- function ENT:Use( activator, caller )
	
-- end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
