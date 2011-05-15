AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

--Sounds
Vo = {}
Vo.Zombie_D = {"npc/zombie/zombie_die1.wav",
"npc/zombie/zombie_die2.wav",
"npc/zombie/zombie_die3.wav",
"npc/zombie/zombie_voice_idle6.wav",
"npc/zombie/zombie_voice_idle11.wav"}

Vo.Zombie_P = {"npc/zombie/zombie_pain1.wav",
"npc/zombie/zombie_pain2.wav",
"npc/zombie/zombie_pain3.wav",
"npc/zombie/zombie_pain4.wav",
"npc/zombie/zombie_pain5.wav",
"npc/zombie/zombie_pain6.wav"}

Vo.Zombie_T = {"npc/zombie/zombie_voice_idle1.wav",
"npc/zombie/zombie_voice_idle2.wav",
"npc/zombie/zombie_voice_idle3.wav",
"npc/zombie/zombie_voice_idle4.wav",
"npc/zombie/zombie_voice_idle5.wav",
"npc/zombie/zombie_voice_idle7.wav",
"npc/zombie/zombie_voice_idle8.wav",
"npc/zombie/zombie_voice_idle9.wav",
"npc/zombie/zombie_voice_idle10.wav",
"npc/zombie/zombie_voice_idle12.wav",
"npc/zombie/zombie_voice_idle13.wav",
"npc/zombie/zombie_voice_idle14.wav"}

Vo.Poison_D = {"npc/zombie_poison/pz_die1.wav",
"npc/zombie_poison/pz_die2.wav",
"npc/zombie_poison/pz_idle2.wav",
"npc/zombie_poison/pz_warn2.wav"}

Vo.Poison_P = {"npc/zombie_poison/pz_idle3.wav",
"npc/zombie_poison/pz_idle4.wav",
"npc/zombie_poison/pz_pain1.wav",
"npc/zombie_poison/pz_pain2.wav",
"npc/zombie_poison/pz_pain3.wav",
"npc/zombie_poison/pz_warn1.wav"}

Vo.Poison_T = {"npc/zombie_poison/pz_alert1.wav",
"npc/zombie_poison/pz_alert2.wav",
"npc/zombie_poison/pz_call1.wav",
"npc/zombie_poison/pz_throw2.wav",
"npc/zombie_poison/pz_throw3.wav"}

Vo.Fast_D = {"npc/fast_zombie/fz_alert_close1.wav",
"npc/fast_zombie/fz_alert_far1.wav"}

Vo.Fast_P = {"npc/fast_zombie/wake1.wav",
"npc/headcrab_poison/ph_poisonbite2.wav",
"npc/headcrab_poison/ph_hiss1.wav",
"npc/headcrab_poison/ph_idle1.wav"}

Vo.Fast_T = {"npc/fast_zombie/fz_frenzy1.wav",
"npc/fast_zombie/fz_frenzy1.wav",
"npc/barnacle/barnacle_bark1.wav",
"npc/barnacle/barnacle_pull1.wav"}

Vo.Claw = {"npc/zombie/claw_strike1.wav",
"npc/zombie/claw_strike2.wav",
"npc/zombie/claw_strike3.wav"}

for k,v in pairs(Vo) do
	for c,d in pairs(Vo[k]) do
		util.PrecacheSound(d)
	end
end

--ENT Vars
ENT.SpawnRagdollOnDeath = true
ENT.BloodType = "red"
ENT.AnimScale = 1
ENT.Damage = 10
ENT.Death = {"runner/death1.wav", "runner/death2.wav"}
ENT.Taunt = {"runner/alert1.wav","runner/alert2.wav"}
ENT.Attack = {"runner/attack.wav","runner/attack2.wav"}
ENT.MeleeAnims = {"swing"}
ENT.LastSeen = CurTime()
ENT.BlockingDoor = NullEntity()
ENT.Leader = NullEntity()

--Utility
function ChooseRandom(tablename)
return tablename[math.random(1,table.Count(tablename))] end

function ENT:VoiceSound(sound,vol)
	vol = vol or 100
	local rnum = math.random(90,100)
	if self.SoundDelay then
		if self.SoundDelay < CurTime() then
			self.SoundDelay = CurTime() + 1.5
			self:EmitSound(sound,vol,rnum)
			WorldSound( sound, self:GetPos(), 75, rnum )
		end
	else
		self.SoundDelay = CurTime() + 1.5
		--self:EmitSound(sound,vol,rnum)
		WorldSound( sound, self:GetPos(), 75, rnum )
	end
end

--Schedules
local schdZombNewWander = ai_schedule.New( "AIZombieNewWanderNode" )
	schdZombNewWander:AddTask( "PlaySequence", 						{ Name = "ACT_IDLE", Speed = 1 } )
	schdZombNewWander:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 		512 )
	schdZombNewWander:EngTask( "TASK_WALK_PATH_TIMED", 				0.5 )
	schdZombNewWander:EngTask( "TASK_WAIT", 						0.5 )
	
local schdZomb = ai_schedule.New( "AIZombieWander" )
	schdZomb:EngTask( "TASK_WALK_PATH_TIMED", 			0.5 )
	schdZomb:EngTask( "TASK_WAIT", 						0.5 )
	
local schdZombChill = ai_schedule.New( "AIZombieChill" )
	schdZombChill:AddTask( "PlaySequence", 				{ Name = "ACT_IDLE", Speed = 1 } )
	schdZombChill:EngTask( "TASK_WAIT", 				math.random( 1, 5 ))
	
local schdZombChse = ai_schedule.New( "AIZombieChase" )
	schdZombChse:EngTask( "TASK_GET_PATH_TO_ENEMY", 		0 )
	schdZombChse:EngTask( "TASK_RUN_PATH_TIMED", 			0.1 )
    schdZombChse:EngTask( "TASK_WAIT", 						0.1 )
	
local schdZombAttack = ai_schedule.New( "AIZombieAttack" )
	schdZombAttack:EngTask( "TASK_STOP_MOVING", 		0 )
	schdZombAttack:EngTask( "TASK_FACE_ENEMY", 			0 )
	schdZombAttack:AddTask( "PlaySequence", 			{ Name = "swing", Speed = 1 } )
	
local schdZombChrgDoor = ai_schedule.New( "AIZombieChargeDoor" )
	schdZombChrgDoor:EngTask( "TASK_GET_PATH_TO_TARGET ", 			0 )
	schdZombChrgDoor:EngTask( "TASK_RUN_PATH_TIMED", 			0.5 )
    schdZombChrgDoor:EngTask( "TASK_WAIT", 						0.5 )

local schdZombBreakDoor = ai_schedule.New( "AIZombieBreakDoor" )
	schdZombBreakDoor:EngTask( "TASK_STOP_MOVING", 		0 )
	schdZombBreakDoor:EngTask( "TASK_FACE_Target", 			0 )
	schdZombBreakDoor:AddTask( "PlaySequence", 			{ Name = "swing", Speed = 1 } )

--NPC Code
function ENT:Initialize()
	self:SetModel( "models/Zed/malezed_0"..ChooseRandom({4,6,8})..".mdl" )
	
	util.PrecacheSound("runner/stalk2.wav")
	util.PrecacheSound("runner/stalk.wav")
 
	self:SetHullType( HULL_HUMAN );
	self:SetHullSizeNormal();
 
	self:SetSolid( SOLID_BBOX ) 
	self:SetMoveType( MOVETYPE_STEP )
 
	self:CapabilitiesAdd( CAP_MOVE_GROUND | CAP_ANIMATEDFACE | CAP_TURN_HEAD | CAP_AIM_GUN )
 
	self:SetMaxYawSpeed( 5000 )
 
	--don't touch stuff above here
	self:SetHealth(100)
	
	self:AddRelationship("player D_HT 99")
	
	
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() <= 0 then --run on death
		self:DoDeath(dmg)
	else
		if math.random(1,3) == 1 then
			self:VoiceSound(ChooseRandom(Vo.Zombie_P),100)
		end
		
		local enemy = self:GetEnemy() or NullEntity()
		local attacker = dmg:GetAttacker()
		
		if enemy:IsValid() and attacker:IsValid() and (attacker:IsPlayer() or attacker:IsNPC()) then
			local targetDistance = self:GetPos():Distance(enemy:GetPos())
			local attackerDistance = self:GetPos():Distance(attacker:GetPos())
			
			if attackerDistance < targetDistance then
				self:SetEnemy(attacker)
				self:UpdateEnemyMemory( attacker, attacker:GetPos() )
			end
		end
	end
end 

function ENT:DoDeath(dmginfo)

	if self.IsDead then self:Remove() return end
	self.IsDead = true

	hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	
	local killer = dmginfo:GetAttacker()

	self:VoiceSound(ChooseRandom(self.Death),100)
			
	local ragdoll = ents.Create("prop_ragdoll")
	ragdoll:SetKeyValue("angles", self:GetAngles().p + math.random(-3,3).." "..self:GetAngles().y +  math.random(-3,3).." "..self:GetAngles().r + math.random(-3,3))
	ragdoll:SetPos(self:GetPos())
	ragdoll:SetModel(self:GetModel())
	ragdoll:Spawn()
	ragdoll:Activate()
	ragdoll:Fire("kill",1,10)
	ragdoll:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	
	for i=1,128 do
		local bone = ragdoll:GetPhysicsObjectNum( i )
		if ValidEntity( bone ) then
			local bonepos, boneang = ragdoll:GetBonePosition( ragdoll:TranslatePhysBoneToBone( i ) )
			bone:SetPos( bonepos )
			bone:SetAngle( boneang )
		end
	end
			
	local phys = ragdoll:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(50)
		local fnum = 900
		if dmginfo:IsExplosionDamage() then 
			fnum = phys:GetMass()^3.2
		else
			fnum = phys:GetMass()^2.1
		end
		phys:AddAngleVelocity(Angle(math.Rand(-1*(fnum/5),fnum/5),math.Rand(-1*(fnum/3),fnum/3),math.Rand(-1*(fnum/5),fnum/5)))
		phys:ApplyForceCenter((ragdoll:GetPos()-killer:GetPos())*math.random(50,200))
	end
			
	self:SetSchedule( SCHED_FALL_TO_GROUND )
	self:Remove()
end

-- function ENT:OnCondition( iCondition )
	
	-- if self:ConditionName( iCondition ) == "COND_CAN_MELEE_ATTACK1" then
		-- self:StartSchedule( schdZombAttack )
	-- end
	
-- end

function ENT:SelectSchedule()
	local enemy = self:GetEnemy()
	local sched = ChooseRandom({schdZomb, schdZomb, schdZomb, schdZombChill})
	local distToGoal = self:GetPathDistanceToGoal() or 0
	local isCustom = true
	
	if not self:OnGround() then
		
	end
	
	if distToGoal < 50 then
		isCustom = true
		sched = schdZombNewWander
	end
	
	if ValidEntity( enemy ) then
		if self:GetPos():Distance( enemy:GetPos() ) < 50 then
			isCustom = true
			sched = schdZombAttack
		else
			local myDistance = self:GetShootPos():Distance(enemy:GetShootPos())
			local tracedata = {}
			tracedata.start = self:GetShootPos()
			tracedata.endpos = enemy:GetShootPos()
			tracedata.filter = self
			local trace = util.TraceLine(tracedata)
			local targetEnt = trace.Entity or NullEntity()
			if (not trace.HitWorld) and ((not trace.HitNonWorld) or targetEnt:IsPlayer()) and myDistance < 2048 then
				ErrorNoHalt("Memory Update Hit.")
				self:UpdateEnemyMemory( enemy, enemy:GetPos() )
				self.LastSeen = CurTime()
			end
			local timeDiff = CurTime() - self.LastSeen
			if timeDiff < 30 then
				local trace = {}
				trace.start = (self:GetPos() + Vector(0,0,60)) + (self:GetAngles():Forward() * -10)
				trace.endpos = trace.start + self:GetAngles():Forward() * 110
				trace.filter = self
				local tr = util.TraceLine(trace) 
				
				local traceEnt = tr.Entity or NullEntity()
				if traceEnt:IsValid() then
					if traceEnt:GetClass() == "prop_door_rotating" and traceEnt:GetLocalAngles().y == 0 then
						self:SetTarget(traceEnt)
						self.BlockingDoor = traceEnt
					end
				else
					isCustom = true
					sched = schdZombChse
				end
			else
				self.LastSeen = CurTime()
				self:ClearEnemyMemory()
				self:EnemySearch( "player", 512 )
			end
			
			
		end
		
		-- local blockingEnt = self:GetBlockingEntity()
		
		-- if blockingEnt and blockingEnt:IsValid() then
			-- ErrorNoHalt("Blocking Class:  "..blockingEnt:GetClass())
			-- if blockingEnt:GetClass() == "prop_door_rotating" then
				-- self:SetTarget(blockingEnt)
				-- self.BlockingDoor = blockingEnt
			-- end
		-- end
		
		if self.BlockingDoor:IsValid() then
			if self:GetPos():Distance( self.BlockingDoor:GetPos() ) < 90 then
				isCustom = true
				sched = schdZombBreakDoor
			else
				isCustom = true
				sched = schdZombChrgDoor
			end
		end
	else
		if math.random(1,100) < 25 then self:VoiceSound(ChooseRandom(Vo.Zombie_T), 100) end
		self:EnemySearch( "player", 512 )
	end
	
	if isCustom then
		self:StartSchedule( sched )
	else
		self:SetSchedule( sched )
	end
end

function ENT:OnRemove( )
	
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end

--SCRIPTED TASKS--
function ENT:EnemySearch( class, radius ) 

	local et =  ents.FindInSphere( self:GetPos(), radius or 512 )
	local closestSeen = NullEntity()
	local distance = radius or 512
	for k, v in ipairs( et ) do 

		if (  v:IsValid() && v != self && v:GetClass() == class  ) then 
			local tracedata = {}
			tracedata.start = self:GetShootPos()
			tracedata.endpos = v:GetShootPos()
			tracedata.filter = self
			local trace = util.TraceLine(tracedata)
			if (not trace.HitWorld) then
				local myDistance = v:GetPos():Distance(self:GetPos())
				if distance >= myDistance then
					distance = myDistance
					closestSeen = v
				end
				self:UpdateEnemyMemory( v, v:GetPos() ) 
			end
			-- end
		end
		
	end
	if closestSeen:IsValid() then
		self:SetEnemy( closestSeen )
		self.LastSeen = CurTime()
	else
		self:SetEnemy( NullEntity() )
	end
end

function ENT:TaskStart_PlaySequence( data )

	local SequenceID = data.ID

	if ( data.Name ) then SequenceID = self:LookupSequence( data.Name )	end

	self:ResetSequence( SequenceID )
	self:SetNPCState( NPC_STATE_SCRIPT )

	local Duration = self:SequenceDuration()

	if ( data.Speed && data.Speed > 0 ) then 

		SequenceID = self:SetPlaybackRate( data.Speed )
		Duration = Duration / data.Speed

	end

	self.TaskSequenceEnd = CurTime() + Duration
	self.HitTime = CurTime() + ((Duration / self.AnimScale) / 3)
	
	if data.Name == "swing" then
		self:EmitSound(self.Attack[math.random(1, table.Count(self.Attack))],100,math.random(85,100))
	end

end

function ENT:Task_PlaySequence( data )
	
	if ( CurTime() > self.HitTime ) and (not self.DidHit) and data.Name == "swing" then
		self.DidHit = true
		
		local trace = {}
		trace.start = (self:GetPos() + Vector(0,0,60)) + (self:GetAngles():Forward() * -10)
		trace.endpos = trace.start + self:GetAngles():Forward() * 110
		trace.filter = self
		local tr = util.TraceLine(trace) 
		if tr.HitWorld or not tr.Entity:IsValid() then 
			return
		end
		if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
			self:EmitSound(ChooseRandom(Vo.Claw),100,math.random(90,110))
			tr.Entity:TakeDamage(self.Damage,self,self)
			if tr.Entity:IsPlayer() then
				tr.Entity:ViewPunch(Angle(math.Rand(2.5,-2.5)*5, math.Rand(2.5,-2.5)*2, 0))
			end
			if math.random(1,3) == 1 then
				self:VoiceSound(ChooseRandom(self.Taunt),100)
			end
		elseif tr.Entity == self.BlockingDoor and self.BlockingDoor:IsValid() then
			local doorent = self.BlockingDoor
			
			if not doorent.integrity then
				doorent.integrity = 100
			end
			
			self:EmitSound(ChooseRandom(Vo.Claw),100,math.random(90,110))
			if doorent.integrity > 0 then
				doorent.integrity = doorent.integrity - 10
			else
				doorent.integrity = 100
				self.BlockingDoor = NullEntity()
				
				doorent:Fire("open", "", 0.1)
				doorent:Fire("unlock", "", 0.1)

				local pos = doorent:GetPos()
				local ang = doorent:GetAngles()
				local model = doorent:GetModel()
				local skin = doorent:GetSkin()

				doorent:SetNotSolid(true)
				if doorent:GetClass() == "prop_door_rotating" then
					doorent:SetNoDraw(true)
				end

				local function ResetDoor(door, fakedoor)
					door:SetNotSolid(false)
					door:SetNoDraw(false)
					if door:GetClass() == "prop_door_rotating" then
						fakedoor:Remove()
					end
				end

				local norm = pos - (self.Entity:GetPos() + self.Entity:GetRight() * 100 + self.Entity:GetUp() * 400)
				if norm.z < 0 then norm.z = 0 end
				norm:Normalize()

				local push = 40000 * norm
				if doorent:GetClass() == "prop_door_rotating" then
					local ent = ents.Create("prop_physics")

					ent:SetPos(pos)
					ent:SetAngles(ang)
					ent:SetModel(model)

					if(skin) then
						ent:SetSkin(skin)
					end

					ent:Spawn()

					timer.Simple(0.01, ent.SetVelocity, ent, push)               
					timer.Simple(0.01, ent:GetPhysicsObject().ApplyForceCenter, ent:GetPhysicsObject(), push)
					timer.Simple(25, ResetDoor, doorent, ent)
				else
					timer.Simple(25, ResetDoor, doorent, NullEntity())
				end
			end
		elseif string.find(tr.Entity:GetClass(),"prop_phys") then
			self:EmitSound(ChooseRandom(Vo.Claw),100,math.random(90,110))
			tr.Entity:TakeDamage(self.Damage,self,self)
			local phys = tr.Entity:GetPhysicsObject()
			if phys:IsValid() then
				phys:ApplyForceCenter(self:GetForward() * 2000)
			end
		end
	end
	
	if CurTime() < self.TaskSequenceEnd then return end
	
	self:TaskComplete()
	self.DidHit = false
	self:SetNPCState( NPC_STATE_NONE )

	// Clean up
	self.TaskSequenceEnd = nil

end
