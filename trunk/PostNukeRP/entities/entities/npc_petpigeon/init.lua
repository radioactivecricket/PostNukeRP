AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

function ENT:Initialize()
	self.Owner = nil
--	self.iNPCState = SCHED_IDLE_WANDER
	self.NPCMode = 0
	self.Waiting = false
	self.Option = 0
	--NPC Modes:
	-- 0 = Wait
	-- 1 = Wonder
	-- -1 = Stay
	-- -2 = Folow
	-- -11 = Run Away
	-- -12 = Hide
	-- -13 = Cower

	self.Pet = true
	self:SetNWString("pet", "yes")
	
	self:SetModel( "models/pigeon.mdl" )
	self:SetHullType( HULL_TINY );
	self:SetHullSizeNormal();
 
	self:SetSolid( SOLID_BBOX ) 
	self:SetMoveType( MOVETYPE_STEP )
 
	self:CapabilitiesAdd( CAP_MOVE_GROUND )
	self:CapabilitiesAdd( CAP_MOVE_JUMP )
	self:CapabilitiesAdd( CAP_MOVE_FLY )
	self:CapabilitiesAdd( CAP_SKIP_NAV_GROUND_CHECK )
	self:CapabilitiesAdd( CAP_TURN_HEAD )
	
	self:SetMaxYawSpeed( 5000 )
 
	self:SetHealth(100)
	
	self:SetNWString("name", "Wild Bird")
	
	self:SelectSchedule( SCHED_IDLE_WANDER )

	self:AddRelationship("npc_pigeon D_HT 999")
	
end

function ENT:SelectSchedule( iNPCState )
	
	if iNPCState ~= nil then
		self.iNPCState = iNPCState
	end
	
	self:SetSchedule( self.iNPCState )

end

function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and IsValid(activator) and activator:IsPlayer() then
		local ply = activator
		if ply:KeyPressed( IN_USE ) then
			if tostring(self:GetNetworkedString( "Owner_UID" , "None" )) == PNRP:GetUID( ply ) then		
				self:CommandSound()
				if self.Option == 0 then
					self.Option = 1
					self.NPCMode = -2
					self:SetTarget( ply )
					self:SelectSchedule( SCHED_TARGET_CHASE )
					ply:ChatPrint("You tell your pet to follow.")
				elseif self.Option == 1 then
					self.Option = 2
					self.NPCMode = -1
					self:SelectSchedule( SCHED_IDLE_STAND )
					ply:ChatPrint("You tell your pet to stay.")
					timer.Create( "hdIdleSound_"..tostring(self), math.random(60), 0, function ()
						if IsValid(self) then
							self:IdleSounds()
						end
					end)
				else
					self.Option = 0
					self.NPCMode = 1
					self:SelectSchedule( SCHED_IDLE_WANDER )
					ply:ChatPrint("You tell your pet to wander.")
				end
			else
				ply:ChatPrint("This pet does not like you.")
			end
		end
	end
end

function ENT:IdleSounds()

end

function ENT:HDAlertSound()

end

function ENT:HDPainSounds()

end

function ENT:CommandSound()

end

function changeActivity(ENT)
	if ENT.Waiting == false then
--		print(tostring(ENT).." State: "..ENT:GetNPCState( ))
		local target = ENT:GetTarget()
		if IsValid(target) then
--			print(tostring(ENT).." Target: "..tostring(target))
		end
		
		if ENT.NPCMode ~= -1 then
			if timer.Exists("hdIdleSound_"..tostring(transENT)) then
				timer.Destroy("hdIdleSound_"..tostring(transENT))
			end
		end
		
		--Stay or Wander
		if ENT.NPCMode >= 0 and ENT:GetNPCState( ) ~= NPC_STATE_COMBAT then -- Wait and Wonder
			ENT.Option = 0
			ENT:SetNPCState(NPC_STATE_IDLE)
			local schedNum = math.random(10)
			if schedNum > 0 then
--				print(tostring(ENT).." Wander")
				ENT.Waiting = true
				ENT.NPCMode = 1
				timer.Simple( math.random(5), function()
					ENT.Waiting = false
				end)
				ENT:SelectSchedule( SCHED_IDLE_WANDER )
			else
--				print(tostring(ENT).." Wait")
				ENT.Waiting = true
				ENT.NPCMode = 0
				timer.Simple( math.random(5), function()
					ENT.Waiting = false
				end)
				ENT:SelectSchedule( SCHED_IDLE_STAND )
				ENT:IdleSounds()
			end		
		end
		
		--Start Hide
		if ENT:GetNPCState( ) == NPC_STATE_COMBAT then --Evasive Action
--			print(tostring(ENT).." Hide")
			ENT.Option = 0
			ENT.Waiting = true
			ENT.NPCMode = -12
			ENT:FoundEnemySound( )
			timer.Simple( math.random(5), function()
				if IsValid(ENT) then
					if !IsValid(ENT:GetEnemy( )) then
						ENT.NPCMode = 0
					end
					ENT.Waiting = false
				end
			end)
			ENT:SelectSchedule( SCHED_TAKE_COVER_FROM_ENEMY )
			ENT:HDAlertSound()
		end
		
		--Star Cower
		if ENT:GetNPCState( ) == NPC_STATE_ALERT then
--			print(tostring(ENT).." Cower")
			ENT.Option = 0
			ENT.Waiting = true
			ENT.NPCMode = -13
			ENT:FoundEnemySound( )
			timer.Simple( math.random(5), function()
				if IsValid(ENT) then
					if ENT.NPCMode < -10 then	
						if IsValid(ENT:GetEnemy( )) then
							print(tostring(ENT:GetEnemy( )))
							ENT.NPCMode = 0
							ENT.Waiting = false
						end
					end
				end
			end)
			ENT:FoundEnemySound( )
			ENT:SelectSchedule( SCHED_COWER )
			ENT:HDAlertSound()
		end
		
		--Fix NPC State
		if ENT:GetNPCState( ) == NPC_STATE_IDLE and ENT.NPCMode < -10 then
--			print(tostring(ENT).." NPC Fix")
			ENT.Option = 0
			ENT.NPCMode = 0
		end
	end
end 

function ENT:ScheduleFinished()
	changeActivity(self)
end
 
function ENT:OnTakeDamage(dmg)
--	self:SetHealth(self:Health() - dmg:GetDamage())
	
--	print(tostring(self).." Run Away")
	self:SelectSchedule( SCHED_MOVE_AWAY_FROM_ENEMY )
	self.NPCMode = -11
	self.Option = 0
	self:HDPainSounds()
	
	if self:Health() <= 0 then --run on death
--		print(tostring(self).." Died")
--		local diesound = Sound("npc/headcrab/die1.wav")
--		self:EmitSound( diesound )
		--self:Remove()
		self:SetNoDraw(true)
		self:SetSolid(SOLID_NONE)
			
		local corpseGib = ents.Create("prop_ragdoll")
		corpseGib:SetModel( self:GetModel() )
		corpseGib:SetPos(self:GetPos())
		corpseGib:SetAngles(self:GetAngles())
		corpseGib:Spawn()
		corpseGib:SetSolid(SOLID_VPHYSICS)
		corpseGib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		corpseGib:Activate()
			
		timer.Simple(10, function ()
			if IsValid(self) then
				self:Remove()
			end
			if IsValid(corpseGib) then
				corpseGib:Remove()
			end
		end )
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
	for k, v in ipairs( et ) do 

		if (  IsValid(v) && v != self && v:GetClass() == class  ) then 
			-- local tracedata = {}
			-- tracedata.start = self:GetShootPos()
			-- tracedata.endpos = v:GetShootPos()
			-- tracedata.filter = self
			-- local trace = util.TraceLine(tracedata)
			-- if trace.HitNonWorld and trace.Entity:IsValid() and trace.Entity == v then
			self:SetEnemy( v, true ) 
			self:UpdateEnemyMemory( v, v:GetPos() ) 
			return 
			-- end
		end
		
	end 

	self:SetEnemy( nil )
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end