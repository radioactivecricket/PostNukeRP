AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

local schdIdle = ai_schedule.New( "AIIdle" )
	schdIdle:EngTask( "TASK_WAIT", 			1 )
	schdIdle:AddTask( "PlaySequence", 				{ Name = "ACT_IDLE", Speed = 1 } )
	
local schdWonder = ai_schedule.New( "AIWonder" )
	schdWonder:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 	128 )
	schdWonder:EngTask( "TASK_RUN_PATH", 			0 )
	schdWonder:EngTask( "TASK_WAIT_FOR_MOVEMENT", 	0 )

local schdWonderJump = ai_schedule.New( "AIWonderJump" )
	schdWonderJump:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 	50 )
	schdWonderJump:EngTask( "TASK_WAIT", 			1 )
	schdWonderJump:AddTask( "PlaySequence", 				{ Name = "ACT_HOP", Speed = 1 } )
	
local schdDefend = ai_schedule.New("AIDefendSelf")
	schdDefend:EngTask("TASK_STOP_MOVING", 0)
	schdDefend:EngTask("TASK_FACE_ENEMY", 0)
	schdDefend:EngTask("TASK_MELEE_ATTACK1", 0)
	

local ZModel = "models/headcrabclassic.mdl"

local NPCMode = "none"

function ENT:Initialize()
	--self:SetModel( "models/humans/corpse1.mdl" )
	self:SetModel( ZModel )
	self:SetHullType( HULL_TINY );
	self:SetHullSizeNormal();
 
	self:SetSolid( SOLID_BBOX ) 
	self:SetMoveType( MOVETYPE_STEP )
 
	self:CapabilitiesAdd( CAP_MOVE_GROUND | CAP_MOVE_JUMP )
	
	self:SetMaxYawSpeed( 5000 )
 
	self:SetHealth(20)
	
--	self:AddRelationship("player D_HT 999")

end
 
function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() <= 0 then --run on death
	
		local diesound = Sound("npc/headcrab/die1.wav")
		self:EmitSound( diesound )
		--self:Remove()
		self:SetNoDraw(true)
		self:SetSolid(SOLID_NONE)
		--self:SetSchedule( SCHED_FALL_TO_GROUND ) --because it's given a new schedule, the old one will end.
		
		local corpseGib = ents.Create("prop_ragdoll")
		corpseGib:SetModel( ZModel )
		corpseGib:SetPos(self:GetPos())
		corpseGib:SetAngles(self:GetAngles())
		corpseGib:Spawn()
		corpseGib:SetSolid(SOLID_VPHYSICS)
		corpseGib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		corpseGib:Activate()
		
		timer.Simple(10, function ()
			self:Remove()
			corpseGib:Remove()
		end )
	end
end 

function ENT:SelectSchedule()
	if NPCMode == "none" then
		local schedNum = math.random(15)
		local schedNum2 = math.random(15)
		if schedNum >= 14 then
			if schedNum2 >= 14 then
				self:StartSchedule( schdWonder ) --Where the jump one will go
			else
				self:StartSchedule( schdWonder )
			end
		else
			self:StartSchedule( schdIdle )
		end
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

		if (  v:IsValid() && v != self && v:GetClass() == class  ) then 
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

	self:SetEnemy( NullEntity() )
end