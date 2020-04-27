AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

--ENT.Model = "models/zombie/classic_legs.mdl"
ENT.Model = "models/zombie/classic.mdl"
--ENT.Model = "models/Humans/Group03/male_07.mdl"
ENT.Damage =  25 
ENT.BaseHealth = 100
ENT.MoveSpeed = 225
ENT.JumpHeight = 80
ENT.BumpSpeed = 500
ENT.MoveAnim = ACT_RUN

ENT.LoseTargetDist = 2000
ENT.SearchRadius = 100
ENT.SightRange = 500
ENT.AlarmDist = 1000

ENT.Alarmed = false
ENT.AlarmPos = nil

ENT.FirstSpawn = true
ENT.LastEnemy = nil
ENT.LastKnownPos = Vector(0,0,0)
ENT.IsBlocked = false
ENT.BlockedEnt = nil

ENT.TraceCounter = CurTime( )

ENT.RunInterrupt = false

ENT.Friends = { "npc_nx_zombie", "npc_nx_zombie_comb", "npc_nx_zombie_fast", "npc_nx_zombie_poisen" }
ENT.Enemies = { "npc_combine_s", "npc_antlion"}

ENT.AlertSound = { "npc/zombie/zombie_alert1.wav", "npc/zombie/zombie_alert2.wav", "npc/zombie/zombie_alert3.wav" }
ENT.AttackSound = { "npc/zombie/zo_attack1.wav", "npc/zombie/zo_attack2.wav" }
ENT.HitSound = { "npc/zombie/claw_strike1.wav" }
ENT.BreaksSound = { "npc/zombie/zombie_pound_door.wav" }
ENT.IdleSounds = {	"npc/zombie/zombie_voice_idle1.wav",
					"npc/zombie/zombie_voice_idle10.wav",
					"npc/zombie/zombie_voice_idle11.wav",
					"npc/zombie/zombie_voice_idle12.wav",
					"npc/zombie/zombie_voice_idle13.wav",
					"npc/zombie/zombie_voice_idle14.wav",
					"npc/zombie/zombie_voice_idle2.wav",
					"npc/zombie/zombie_voice_idle3.wav",
					"npc/zombie/zombie_voice_idle4.wav",
					"npc/zombie/zombie_voice_idle5.wav",
					"npc/zombie/zombie_voice_idle6.wav",
					"npc/zombie/zombie_voice_idle7.wav",
					"npc/zombie/zombie_voice_idle8.wav",
					"npc/zombie/zombie_voice_idle9.wav"	}
ENT.MadSounds = {	"npc/zombie/moan_loop1.wav",
					"npc/zombie/moan_loop2.wav",
					"npc/zombie/moan_loop3.wav",
					"npc/zombie/moan_loop4.wav" }
ENT.PainSounds = {	"npc/zombie/zombie_pain1.wav",
					"npc/zombie/zombie_pain2.wav",
					"npc/zombie/zombie_pain3.wav",
					"npc/zombie/zombie_pain4.wav",
					"npc/zombie/zombie_pain5.wav",
					"npc/zombie/zombie_pain6.wav" }
ENT.DeathSounds = {	"npc/zombie/zombie_die1.wav",
					"npc/zombie/zombie_die2.wav",
					"npc/zombie/zombie_die3.wav" }
					
function ENT:Initialize()

	self:SetModel( self.Model )
	self:SetBodygroup( 1, 1 ) 
	
	self.Entity:SetHealth( self.BaseHealth )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_NPC )
	
	self.loco:SetAcceleration( 500 )
	self.loco:SetDeceleration( 40000 )
	self.loco:SetStepHeight( 18 )
	self.loco:SetJumpHeight( 50 )
		
end

function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and IsValid(activator) and activator:IsPlayer() then
		local ply = activator
		if ply:KeyPressed( IN_USE ) then
			local enemy = self:GetEnemy()
			ply:ChatPrint("Enemy: "..tostring(enemy))
			ply:ChatPrint("IsBlocked: "..tostring(self.IsBlocked))
		end
	end
end

----------------------------------------------------
-- ENT:RunBehaviour()
-- This is where the meat of our AI is
----------------------------------------------------
function ENT:RunBehaviour()
	-- This function is called when the entity is first spawned. It acts as a giant loop that will run as long as the NPC exists
	while ( true ) do

		if self.FirstSpawn then
			self:PlaySequenceAndWait( "canal5await" )
			coroutine.wait( math.Rand( 10, 30) ) --10,30
			self:PlaySequenceAndWait( "slumprise_b" )
			self:EmitSound( table.Random( self.IdleSounds ), math.Rand( 300, 355), 100  )
			self.FirstSpawn = false
			self:FindEnemy()
		else
			local enemy = self:GetEnemy()
			local selfPos = self:GetPos()
			
			if self:HaveEnemy() and IsValid(enemy) then
				local e_pos = enemy:GetPos()
				if self.LastEnemy ~= enemy then
					if IsValid(e_pos) then self.loco:FaceTowards( e_pos ) end
					self:EmitSound( table.Random( self.AlertSound ), 355, 100  )
					self:PlaySequenceAndWait( "FireIdle" )
					
					local ents_alarmed = ents.FindInSphere( selfPos, self.AlarmDist )
					for k,v in pairs(ents_alarmed) do
						if IsValid(v) and table.HasValue( self.Friends, v:GetClass() ) then
							v:HearAlert(selfPos)
						end
					end
				end
				-- self.loco:FaceTowards( self:GetEnemy():GetPos() )
				self:StartActivity( ACT_WALK )			-- Set the animation
				self.loco:SetDesiredSpeed( 50 )		-- Set the speed that we will be moving at. Don't worry, the animation will speed up/slow down to match
				self.loco:SetAcceleration( 60 )			-- We are going to run at the enemy quickly, so we want to accelerate really fast
				self:ChaseEnemy()
				
				self.Entity:StartActivity( ACT_IDLE_RELAXED )
				coroutine.yield()
			elseif self.Alarmed then
				self.Alarmed = false
				
				self:EmitSound( table.Random( self.IdleSounds ), math.Rand( 300, 355), 100  )
				self:PlaySequenceAndWait( "Tantrum" )
				
				if self.AlarmPos then
					self:StartActivity( ACT_WALK )			-- Walk anmimation
					self.loco:SetDesiredSpeed( 50 )		-- Walk speed
					local goto_pos = self.AlarmPos + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * math.random(20, 50 )
					
					if self:MoveToPos( goto_pos ) == "stuck" then
						goto_pos = self:GetPos() + (self:EyeAngles():Forward() * -1 * math.random(50,100))
						self:MoveToPos( goto_pos )
					end
					
					-- Walk to a random place within about 400 units ( yielding )
					self.Entity:StartActivity( ACT_IDLE_RELAXED ) 
				end
				self.AlarmPos = nil
				coroutine.yield()
			else
				if math.Rand(0, 100) < 60 then		
					self:StartActivity( ACT_WALK )			-- Walk anmimation
					self.loco:SetDesiredSpeed( math.Rand(20, 50))		-- Walk speed
					local wander_pos = self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * math.random(100, 400 )
					
					if self:MoveToPos( wander_pos ) == "stuck" then
						wander_pos = self:GetPos() + (self:EyeAngles():Forward() * -1 * math.random(50,100))
						self:MoveToPos( wander_pos )
					end
					
					-- Walk to a random place within about 400 units ( yielding )
					self.Entity:StartActivity( ACT_IDLE_RELAXED ) 
					coroutine.yield()
				else
					if math.Rand(0, 100) < 5 then
						self:PlaySequenceAndWait( "slump_a" )
						for i=1, math.random(20, 60)*2  do
							if self:FindEnemy() then break end
							if self.Alarmed then break end
							coroutine.wait(0.5)
						end
						self:PlaySequenceAndWait( "slumprise_a2" )
					else
						self.Entity:StartActivity( ACT_IDLE_RELAXED ) 
						for i=1, math.random(2, 5)*2  do
							if self:FindEnemy() then break end
							if self.Alarmed then break end
							coroutine.wait(0.5)
						end
					end

				end
				self:FindEnemy()
				if self:HaveEnemy() then
					coroutine.yield()
				else
					coroutine.wait( math.Rand( 2, 20) )
				end
			end
			if math.random(0, 4) < 3 then
				self:EmitSound( table.Random( self.IdleSounds ), math.Rand( 300, 355), 100  )
			end
		end
		
	end

end	

function ENT:MoveToPos( pos, options )

	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 200 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, pos )

	if ( !path:IsValid() ) then return "failed" end
	
	while ( path:IsValid() ) do

		path:Update( self )

		-- Draw the path (only visible on listen servers or single player)
		if ( options.draw ) then
			path:Draw()
		end

		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			
			self:HandleStuck()
			
			return "stuck"

		end

		--
		-- If they set maxage on options then make sure the path is younger than it
		--
		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then return "timeout" end
		end

		--
		-- If they set repath then rebuild the path every x seconds
		--
		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
		end
		
		--Looks for doors and other future things
		--And returns stuck
		if CurTime( ) >= self.TraceCounter then
			local tracedata = {}
			tracedata.start = self:GetPos() + ( self:EyeAngles():Forward() + Vector( 0, 0, 20 ) )
			tracedata.endpos = self:GetPos() + ( self:EyeAngles():Forward() * 20 )
			tracedata.filter = self
			tracedata.mins = self:OBBMins()
			tracedata.maxs = self:OBBMaxs()
			local TraceRes = util.TraceHull( tracedata )
			local seeEnt = TraceRes.Entity
			self.TraceCounter = CurTime( ) + 1
			if IsValid(seeEnt) then
				local entClass = TraceRes.Entity:GetClass()
				if entClass == "prop_door" or  entClass == "prop_door_rotating" or  entClass == "func_door" or  entClass == "func_door_rotating" then
					
					return "stuck"
				end
			end
		end
		
		-- print("I ran a find enemy.")
		
		-- Return to behaviour function with new target after interrupt.
		if self.RunInterrupt then
			self.RunInterrupt = false
			return "ok"
		end
		
		-- Return to behaviour function if you're alarmed, so we can change target positions.
		if self.Alarmed then
			return "ok"
		end
		
		-- Run periodicaly during the walk.
		if self:FindEnemy() then return "ok" end
		
		coroutine.yield()

	end

	return "ok"

end

function ENT:OnStuck()
	
--	print("OnStuck")
end

----------------------------------------------------
-- Injury Interrupt Handling
----------------------------------------------------
function ENT:OnInjured(dmginfo)
	if(IsValid(self)) then
		local playSound = false
		if !self.hurtSCounter then
			playSound = true
		elseif CurTime( ) >= self.hurtSCounter then
			playSound = true
		else
			playSound = false
		end
		
		if playSound then
			local playFile = table.Random( self.PainSounds )
			self.hurtSCounter = CurTime( )+SoundDuration( playFile ) + 3
			self:EmitSound( playFile, 325, 100  )
			playSound = false
		end
	end
	
	-- See if it's a valid target.
	if  IsValid(dmginfo:GetAttacker()) and (dmginfo:GetAttacker():IsPlayer() or table.HasValue( self.Enemies, dmginfo:GetAttacker():GetClass() ) ) then
		-- Do I Have a current target?
		if IsValid(self:GetEnemy()) and ( self:GetEnemy():IsPlayer() or table.HasValue( self.Enemies, self:GetEnemy():GetClass() ) ) then
			-- No need to run the complicated bullshit if it's the same guy.
			if dmginfo:GetAttacker() == self:GetEnemy() then return end
			
			--  Is it closer than the other target and in aggro range?
			if self:GetPos():Distance(dmginfo:GetAttacker():GetPos()) < self:GetPos():Distance(self.LastKnownPos) and self:GetPos():Distance(dmginfo:GetAttacker():GetPos()) < (self.LoseTargetDist/2) then
				--Switch targets
				self:SetEnemy(dmginfo:GetAttacker())
				self.RunInterrupt = true
				
			end
		else
			-- Is it in aggro range?
			if self:GetPos():Distance(dmginfo:GetAttacker():GetPos()) < (self.LoseTargetDist/2) then
				self:SetEnemy(dmginfo:GetAttacker())
				self.RunInterrupt = true
			end
		end
	end
end

----------------------------------------------------
-- ENT:Get/SetEnemy()
-- Simple functions used in keeping our enemy saved
----------------------------------------------------
function ENT:SetEnemy( ent )
	self.Enemy = ent
end
function ENT:GetEnemy()
	return self.Enemy
end

--Looks to see if the enemy is in range.
function ENT:EnemyInRange()
	return ( self.Enemy:GetPos():Distance( self:GetPos() ) <= 90 )
end


--This function may not be needed any more. Will delete later
function ENT:IFoundSomeone()
local plys =  player.GetAll( )
	for k, v in pairs( plys ) do
		if ( v:IsPlayer() and !self:EnemyInRange() and v:GetPos():Distance( self:GetPos() ) < 50 ) then
			self.Enemy = v
			return true
		end
	end
end
----------------------------------------------------
-- ENT:HaveEnemy()
-- Returns true if ( we have a enemy
----------------------------------------------------
function ENT:HaveEnemy()
	-- If our current enemy is valid
	if self:GetEnemy() then
		if IsValid( self:GetEnemy() ) then
			-- If the enemy is dead( we have to check if ( its a player before we use Alive() )
			if ( self:GetEnemy():IsPlayer() and !self:GetEnemy():Alive() ) then
				return self:FindEnemy()		-- Return false if ( the search finds nothing
			--If have enemy
			elseif ( self:GetEnemy() != nil  and self.Enemy:IsValid() ) then
				local tracedata = {}
				tracedata.start = self:GetPos() + ( self:EyeAngles():Forward() + Vector( 0, 0, 20 ) )
				tracedata.endpos = self:GetPos() + ( self:EyeAngles():Forward() * 60 + Vector( 0, 0, 20 ) )
				tracedata.filter = self
				tracedata.mins = self:OBBMins()
				tracedata.maxs = self:OBBMaxs()
				if ( self:EnemyInRange() ) then --If Enemy is in Range, run Attack
					self:AttackPlayer(tracedata)
				else --Else check for props or doors in the way
					self:AttackProp(tracedata)
					self:AttackDoor(tracedata)
				end
			end	
			
			-- Make sure we can see our target.
			local searchOrigin = self:GetPos() + Vector( 0, 0, 20 )
				
			local tracedata = {}
			tracedata.start = searchOrigin 
			tracedata.endpos = self:GetEnemy():GetShootPos()
			tracedata.filter = self
			tracedata.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX
			tracedata.mins = self:OBBMins()
			tracedata.maxs = self:OBBMaxs()
			
			local TraceRes = util.TraceHull( tracedata )
			if ( self:GetPos():Distance(self:GetEnemy():GetPos()) < self.LoseTargetDist and not IsValid(TraceRes.Entity) ) then
				self.LastKnownPos = self:GetEnemy():GetPos()
			elseif (self:GetPos():Distance(self.LastKnownPos) < 50) then
				self:EmitSound( table.Random( self.AlertSound ), 355, 100  )
				self:PlaySequenceAndWait( "Tantrum" )
				
				return self:FindEnemy()
			end
			
			-- Run checks for aggro interrupts.  Change to more relevent targets.
			self:AggroInterrupt( (not IsValid(TraceRes.Entity) ) )
			
			-- The enemy is neither too far nor too dead so we can return true
			return true
		end
	else
		-- The enemy isn't valid so lets look for a new one
		return self:FindEnemy()
	end
end

----------------------------------------------------
-- ENT:FindEnemy()
-- Returns true and sets our enemy if ( we find one
----------------------------------------------------
function ENT:FindEnemy()
	-- Set search origin, because I use it a few times.
	local searchOrigin = self:GetPos() + Vector( 0, 0, 20 )

	-- Search around us for entities
	-- For entities that may be heard
	local ents_heard = ents.FindInSphere( self:GetPos(), self.SearchRadius )
	-- For entities that may be seen
	local ents_seen = ents.FindInCone( searchOrigin, self:EyeAngles():Forward(), self.SightRange , 90 )
	
	-- Create a temporary table for both.
	local ents_targets = {}
	
	-- Run through the two tables for valid enemies.
	for k,v in pairs(ents_heard) do
		if ( v:IsPlayer() or table.HasValue( self.Enemies, v:GetClass() ) ) and v ~= self then
			table.insert(ents_targets, v)
		end
	end
	
	for k,v in pairs(ents_seen) do
		if ( v:IsPlayer() or table.HasValue( self.Enemies, v:GetClass() ) ) and v ~= self then --Runs through the list of Enemies and looks for them
			local tracedata = {}
			tracedata.start = searchOrigin 
			tracedata.endpos = v:GetShootPos()
			tracedata.filter = self
			tracedata.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX
			tracedata.mins = self:OBBMins()
			tracedata.maxs = self:OBBMaxs()
			
			local TraceRes = util.TraceHull( tracedata )
			if ( not IsValid(TraceRes.Entity) ) then
				table.insert(ents_targets, v)
			end
		end
	end
	
	-- If I didn't find anything...
	if #ents_targets <= 0 then
		self:SetEnemy( nil )
		return false
	end
	
	-- We found stuff, so let's see what's closest.
	local curDistance = 65535
	local curEntity = nil
	for k,v in pairs(ents_targets) do
		local myDistance = searchOrigin:Distance(v:GetPos())
		if myDistance < curDistance then
			curDistance = myDistance
			curEntity = v
		end
	end
	
	-- Make sure entity is valid.
	if not IsValid(curEntity) then
		-- It's not!  Purge that shit!
		self:SetEnemy( nil )
		return false
	end
	
	-- Select the enemy.
	self:SetEnemy( curEntity )
	self.LastKnownPos = curEntity:GetPos()

	return true
end

----------------------------------------------------
-- ENT:AggroInterrupt()
-- Returns true if we should run an interrupt.
-- Enemy seen is a bool that says whether or not the
-- current target was seen by trace.
----------------------------------------------------
function ENT:AggroInterrupt( enemySeen )
	-- If we don't have an enemy, no need for interrupts.  Just drop out of function.
	if not self:GetEnemy() then return false end
	
	local searchOrigin = self:GetPos() + Vector( 0, 0, 20 )
	local ents_seen = ents.FindInCone( searchOrigin, self:EyeAngles():Forward(), self.SightRange , 90 )
	
	-- If I didn't find anything...
	if #ents_seen <= 0 then
		return false
	end
	
	if not enemySeen then
		-- See what's closest.
		local curDistance = 65535
		local curEntity = nil
		for k,v in pairs(ents_seen) do
			if IsValid(v) and ( v:IsPlayer() or table.HasValue( self.Enemies, v:GetClass() ) ) and v ~= self then
				local myDistance = searchOrigin:Distance(v:GetPos())
				
				-- Run LOS check
				local tracedata = {}
				tracedata.start = searchOrigin 
				tracedata.endpos = v:GetShootPos()
				tracedata.filter = self
				tracedata.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX
				tracedata.mins = self:OBBMins()
				tracedata.maxs = self:OBBMaxs()
				
				local TraceRes = util.TraceHull( tracedata )
				if ( not IsValid(TraceRes.Entity) ) then
					if myDistance < curDistance then
						curDistance = myDistance
						curEntity = v
					end
				end
			end
		end
		
		-- Make sure entity is valid.
		if not IsValid(curEntity) then
			-- It's not!  Purge that shit!
			return false
		end
		
		-- Select the enemy.
		self:SetEnemy( curEntity )
		self.LastKnownPos = curEntity:GetPos()
		return true
	else
		-- See what's closest.
		-- We set the current enemy as default to make sure.
		local curDistance = searchOrigin:Distance(self:GetEnemy():GetPos())
		local curEntity = self:GetEnemy()
		for k,v in pairs(ents_seen) do
			if IsValid(v) and ( v:IsPlayer() or table.HasValue( self.Enemies, v:GetClass() ) ) and v ~= self then
				local myDistance = searchOrigin:Distance(v:GetPos())
				
				-- Run LOS check
				local tracedata = {}
				tracedata.start = searchOrigin 
				tracedata.endpos = v:GetShootPos()
				tracedata.filter = self
				tracedata.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX
				tracedata.mins = self:OBBMins()
				tracedata.maxs = self:OBBMaxs()
				
				local TraceRes = util.TraceHull( tracedata )
				if ( not IsValid(TraceRes.Entity) ) then
					if myDistance < curDistance then
						curDistance = myDistance
						curEntity = v
					end
				end
			end
		end
		
		-- Same person the most relevent target?  Just return false.
		if curEntity == self:GetEnemy() then return false end
		
		-- Make sure entity is valid.
		if not IsValid(curEntity) then
			-- It's not!  Purge that shit!
			return false
		end
		
		-- Select the enemy.
		self:SetEnemy( curEntity )
		self.LastKnownPos = curEntity:GetPos()
		return true
	end
end

----------------------------------------------------
-- ENT:HearAlert(vec pos)
-- This will make the npc walk towards the alarm
-- sound.  It's a normal move, so just seeing 
-- someone will break him off of it.
----------------------------------------------------
function ENT:HearAlert(pos)
	-- If you have an enemy already, just ignore the alert.
	if self:HaveEnemy() and IsValid(enemy) then return end
	self.AlarmPos = pos
	self.Alarmed = true
end

function ENT:ChaseEnemy( options )

	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	
	path:Compute( self, self.LastKnownPos )		-- Compute the path towards the enemies position
	
	if (  !path:IsValid() ) then return "failed" end

	while ( path:IsValid() and self:HaveEnemy() ) do
		if self.IsBlocked then
			if ( path:GetAge() > 2.5 ) then	--If blocked then will try and go around
				local blockedEnt = self.BlockedEnt
				local newPos

				if IsValid(blockedEnt) then
					--If blocked Ent is a Friendly then will turn and move
					--Else will move to the side and back
					if table.HasValue( self.Friends, blockedEnt:GetClass() ) then
						newPos = self:GetPos() + (self:EyeAngles():Right() * math.random(50,120))
					else
						newPos = self:GetPos() + (self:EyeAngles():Right() * math.random(60,150)) + (self:EyeAngles():Forward() * -1 * math.random(20,50))
					end
				else --If no valid ent, then will just move to the side and back
					newPos = self:GetPos() + (self:EyeAngles():Right() * math.random(60,150)) + (self:EyeAngles():Forward() * -1 * math.random(20,50))
				end
				path:Compute( self, newPos )
				self.IsBlocked = false
			end
		else
			if ( path:GetAge() > 0.1 ) then					-- Since we are following the player we have to constantly remake the path
				path:Compute( self, self.LastKnownPos )-- Compute the path towards the enemy's position again
			end
		end
		path:Update( self )								-- This function moves the bot along the path
		
--		local playSound = false
--		if !self.madSCounter then
--			playSound = true
--		elseif CurTime( ) >= self.madSCounter then
--			playSound = true
--		else
--			playSound = false
--		end
		
--		if playSound == true then
--			local playFile = table.Random( self.MadSounds )
--			self.madSCounter = CurTime( )+SoundDuration( playFile ) + math.random(5,10)
--			self:EmitSound( playFile, 325, 100  )
--			print(tostring(self.madSCounter))
--			playSound = false
--		end
		
		if ( options.draw ) then path:Draw() end
		-- If we're stuck, ) then call the HandleStuck function and abandon
		
		-- Return to behaviour function with new target after interrupt.
		if self.RunInterrupt then
			self.RunInterrupt = false
			return "ok"
		end
		
		--if Stuck return stuck
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end
		
		coroutine.yield()

	end

	return "ok"

end

function ENT:AttackPlayer(tracedata)
	
	local TraceRes = util.TraceHull( tracedata )
	if ( TraceRes.Entity == self.Enemy ) then

		self:StartActivity( ACT_MELEE_ATTACK1 )
		self:EmitSound( table.Random( self.AttackSound ), 355, 100 )
		coroutine.wait( 1 )
		
		if ( IsValid( TraceRes.Entity ) ) then
		local Target = TraceRes.Entity
			if (  self:EnemyInRange() ) then
				Target:TakeDamage( self.Damage, self )
				self:EmitSound( table.Random( self.HitSound ), 355, 100 )
			end
		end
		coroutine.wait( 0.5 ) --For attack to finish
		self:StartActivity( ACT_WALK )
	else
		if ( IsValid( TraceRes.Entity ) ) then
			if table.HasValue( self.Friends, TraceRes.Entity:GetClass() ) then
				self.IsBlocked = true
				self.BlockedEnt = TraceRes.Entity
			end
		end
	end
end

function ENT:AttackProp(tracedata)	
	local TraceRes = util.TraceHull(tracedata)
	if ( TraceRes.Hit ) then
		if ( IsValid( TraceRes.Entity ) and TraceRes.Entity != NULL ) then
			if string.match( TraceRes.Entity:GetClass(), "prop_physics" ) or string.match( TraceRes.Entity:GetClass(), "func_breakable" ) then
				
				if IsValid( TraceRes.Entity ) then
				local Target = TraceRes.Entity
				local phys = Target:GetPhysicsObject()
				if ( phys != nil and phys != NULL and phys:IsValid() ) then
					if phys:IsMotionEnabled( ) or Target:Health( ) > 0 then
						self:EmitSound( table.Random( self.AttackSound ), 355, 100 )
						self:StartActivity( ACT_MELEE_ATTACK1 )
						
						coroutine.wait( 1 )
						
						--To keep item from being reduced to 0 and possible not attacked again or destroyed
						local doDMgCalc = self.Damage
						if doDMgCalc == Target:Health( ) then doDMgCalc = Target:Health( )-1
						else doDMgCalc = self.Damage end
						
						phys:ApplyForceCenter( self:GetForward():GetNormalized()*60000 +self.Enemy:GetPos() )
						Target:EmitSound( table.Random( self.BreaksSound ), 355, 100 )
						Target:TakeDamage( doDMgCalc, self )
						
						self.IsBlocked = false
					--	print("PropHP: "..tostring(Target:Health( ) ))
					else
						self.IsBlocked = true
						self.BlockedEnt = Target
					end
				end
			
				coroutine.wait( 0.5 )
				self:StartActivity( ACT_WALK )
				return true
			end
		end
		
		self:StartActivity( ACT_WALK )	
		return false
		end
	end
end


function ENT:AttackDoor(tracedata)
	
	local TraceRes = util.TraceHull(tracedata)
	if ( TraceRes.Hit ) then
		if ( IsValid( TraceRes.Entity ) and TraceRes.Entity != NULL ) then
			local entClass = TraceRes.Entity:GetClass()
			if entClass == "prop_door" or  entClass == "prop_door_rotating" or  entClass == "func_door" or  entClass == "func_door_rotating" then
				local doorent = TraceRes.Entity
				self:EmitSound( table.Random( self.AttackSound ), 355, 100 )
				self:StartActivity( ACT_MELEE_ATTACK1 )
				
				coroutine.wait( 1 )
				if IsValid( TraceRes.Entity ) then
					
					-- local phys = doorent:GetPhysicsObject()
					-- if ( phys != nil and phys != NULL and phys:IsValid() ) then
					-- phys:ApplyForceCenter( self:GetForward():GetNormalized()*60000 +self.Enemy:GetPos() )
					doorent:EmitSound( table.Random( self.BreaksSound ), 355, 100 )
					-- doorent:TakeDamage( self.Damage, self )
					
					if doorent.LastHit then
						if CurTime() > doorent.LastHit + 300 then
							doorent.Hits = math.random(10,15)
						end
						
						doorent.LastHit = CurTime()
						doorent.Hits = doorent.Hits - 1
					else
						doorent.LastHit = CurTime()
						doorent.Hits = math.random(10,15)
						
						doorent.Hits = doorent.Hits - 1
					end
					
					if doorent.Hits and doorent.Hits <= 0 then
						doorent:Fire("unlock", "", 0.1)
						doorent:Fire("open", "", 0.1)

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

							timer.Simple(0.01, function()
									ent:SetVelocity(push)
									ent:GetPhysicsObject():ApplyForceCenter(push)
								end)
							timer.Simple(25, function()
									ResetDoor( doorent, ent)
								end)
						else
							timer.Simple(25, function()
									ResetDoor( doorent, nil)
								end)
						end
					end
				end
			
				coroutine.wait( 0.5 )
				self:StartActivity( ACT_WALK )
				return true
			end
		end
		
		self:StartActivity( ACT_WALK )	
		return false
		
	end
end
