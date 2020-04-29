AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.AddNetworkString("ladder_assemble")
util.AddNetworkString("ladder_disassemble")
util.AddNetworkString("ProgBar")

util.PrecacheModel ("models/props_c17/metalladder001.mdl")

function ENT:Initialize()	
	self.Entity:SetModel("models/props_c17/metalladder001.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.entOwner = nil
	self.moveActive = true
	self.Entity:PhysWake()
	self.assembled = false
	self.BlockF2 = false
	self.maxTime = 1
	
	self.ladderEntB = nil
	self.entOwner = nil
end

function LadderAssemble(pl, ent)
	ent:EmitSound("physics/metal/metal_sheet_impact_hard"..tostring(math.random(6,8))..".wav",100,100)
	pl:ChatPrint("Assembled!")
	ent.building = false
	ent.BlockF2 = true
	pl:SetMoveType(2)
	
	net.Start("stopProgressBar")
	net.Send(pl)

	--Keeps ladder from being moved.
	ent:SetMoveType(MOVETYPE_NONE)
	ent.assembled = true
	ent.moveActive = false
--	ent:SetCollisionGroup(COLLISION_GROUP_NONE)
	ent:GetPhysicsObject():EnableMotion(false)
	
	--Makes the ladder work!
	ent.ladderEntB = ents.Create("func_useableladder")
	ent.ladderEntB:SetAngles(ent:GetAngles())
	
	local point0 = ent:LocalToWorld( Vector(23, 0, -10) )
	local point1 = ent:LocalToWorld( Vector(23, 0, 130) )
	
	ent.ladderEntB:SetKeyValue("point0", point0.x .." ".. point0.y .." ".. point0.z )
	ent.ladderEntB:SetKeyValue("point1", point1.x .." ".. point1.y .." ".. point1.z )
	ent.ladderEntB:SetKeyValue("origin", point0.x .." ".. point0.y .." ".. point0.z )
	ent.ladderEntB:Spawn()
	ent.ladderEntB:Activate()
	end

function LadderDisassemble(pl, ent)
	ent:EmitSound("physics/metal/metal_sheet_impact_hard"..tostring(math.random(6,8))..".wav",100,100)
	ent.building = false
	ent:SetMoveType(MOVETYPE_VPHYSICS)
	ent.moveActive = true
	ent.assembled = false
	ent.BlockF2 = false
	pl:SetMoveType(2)
	pl:ChatPrint("Disassembled!")
	
	net.Start("stopProgressBar")
	net.Send(pl)
	
	if ent.ladderEntB then
		if ent.ladderEntB:IsValid() then
			ent.ladderEntB:Remove()
		end
	end
end

function ENT:Use( activator, caller )
	if activator:KeyPressed( IN_USE ) and not self.building then
				
		if self.entOwner == "none" then
			self.entOwner = activator
		end
		
		net.Start("ladder_menu")
			net.WriteEntity(self.Entity)
			net.WriteBit(self.assembled)
		net.Send(activator)
	end
end
util.AddNetworkString("ladder_menu")

function ENT:OnRemove()
	if self.ladderEntB then
		if self.ladderEntB:IsValid() then
			self.ladderEntB:Remove()
		end
	end
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end

function ToggleAssembly()
	local pl = net.ReadEntity()
	local ent = net.ReadEntity()

	ent.building = true
	ent.ctm= CurTime()
	ent:EmitSound("ambient/random_amb_sounds/rand_metalsq_0"..tostring(math.random(1,4))..".wav",100,100)
	pl:SelectWeapon("weapon_simplekeys")
	
	net.Start("startProgressBar")
		net.WriteDouble(tonumber(3))
	net.Send(pl)
	
	if ent.assembled == false then
		pl:ChatPrint("Assembling, finishing in 3 seconds!")
		pl:SetMoveType(0)
		ent.BlockF2 = true
		timer.Create("build1",3,1,function() LadderAssemble(pl, ent) end)
	else
		pl:ChatPrint("Disassembling, finishing in 3 seconds!")
		pl:SetMoveType(0)
		ent.BlockF2 = true
		timer.Create("build1",3,1,function() LadderDisassemble(pl, ent) end)
	end
end
net.Receive( "ladder_assemble", ToggleAssembly )
net.Receive( "ladder_disassemble", ToggleAssembly )
