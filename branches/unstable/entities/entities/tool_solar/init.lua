AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.AddNetworkString("togglesolgen_stream")
util.AddNetworkString("repsolgen_stream")

util.PrecacheModel("models/hunter/plates/plate1x2.mdl")

function ENT:Initialize()	
	self.Entity:SetModel("models/hunter/plates/plate1x2.mdl")
	self.Entity:SetMaterial("Solar Panel/Solar/Solar panel NEW")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetHealth( 200 )
	self.entOwner = "none"
	self.moveActive = true
	self.Entity:PhysWake()
	
	self.Status = false
	self.PowerLevel = 0
	self.PowerItem = true
	self.PowerGenerator = true
	self.entOwner = "none"
	
	self.UnitLeft = 0
	
	self.genSound = CreateSound( self, "ambient/machines/combine_shield_loop3.wav" )
	
	-- This var will store the Entity that controls the power network information.
	self.NetworkContainer = nil
	
	self.LinkedItems = {}
	self.DirectLinks = {}
	
	self.Entity:NextThink(CurTime() + 1.0)
end

function ENT:Use( activator, caller )
	if activator:KeyPressed( IN_USE ) then
		if self.Repairing then
			if self.Repairing == activator then
				self.Repairing = nil
				activator:ChatPrint("You stop repairing the generator.")
				
				activator:SetMoveType(MOVETYPE_WALK)
				net.Start("stopProgressBar")
				net.Send(activator)
				self.Repairing = nil
				if self:IsValid() then 
					timer.Stop(activator:UniqueID().."_repair_"..tostring(self))
				end
			else
				activator:ChatPrint("This generator is currently being repaired.")
			end
		else
			if activator:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1 then
				
			end
					
			if self.entOwner == "none" then
				self.entOwner = activator:Nick()
			end
			
			-- if self.Status == "off" then
				-- self.Status = "on"
				-- self.PowerLevel = 500
				
				-- self:GetPhysicsObject():EnableMotion(false)
				-- self.moveActive = false
				-- self:UpdatePower()
			-- elseif self.Status == "on" then
				-- self.Status = "off"
				-- self.PowerLevel = 0
				
				-- --self:GetPhysicsObject():EnableMotion(true)
				-- self.moveActive = true
				-- self:UpdatePower()
			-- else
				
			-- end
			
			-- activator:ChatPrint("You switch the power to "..self.Status)
			
			-- local actInv = PNRP.Inventory( activator )
			-- local availFuel = actInv["fuel_gas"]

			net.Start("solgen_menu")
				net.WriteDouble(self:Health())
				if self.NetworkContainer then
					net.WriteDouble(self.NetworkContainer.NetPower or self.PowerLevel)
				else
					net.WriteDouble(self.PowerLevel)
				end
				net.WriteDouble(0)
				net.WriteDouble(availFuel or 0)
				net.WriteBit(self.Status)
				net.WriteBit(false)
				net.WriteEntity(self.Entity)
				net.WriteEntity(activator)
			net.Send(activator)
		end
	end
end
util.AddNetworkString("solgen_menu")

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() < 200 then self.BlockF2 = true end
	if self:Health() <= 0 then --run on death
		self:SetHealth( 0 )
		
		local ownerEnt = self:GetNWEntity( "ownerent" )
		if ownerEnt then
			PNRP.TakeFromWorldCache( ownerEnt, "tool_solar" )
		end
		self:EmitSound("physics/glass/glass_sheet_break1.wav", 100, 100)
		self:Remove()
	end
end 

function ENT:TogglePower()
	if not self.Status then
		if self:IsOutside() then
			self.Status = true
			self.PowerLevel = 75
			
			--self:GetPhysicsObject():EnableMotion(false)
			--self.moveActive = false
			if self.NetworkContainer then
				self.NetworkContainer:UpdatePower()
			else
				self:UpdatePower()
			end
			self.genSound:Play()
			self.genSound:ChangeVolume(0.18, 0)
		end
	elseif self.Status then
		self.Status = false
		self.PowerLevel = 0
		
		--self.moveActive = true
		if self.NetworkContainer then
			self.NetworkContainer:UpdatePower()
		else
			self:UpdatePower()
		end
		self.genSound:Stop()
	end
end

function ENT.TogglePowerNet()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	if not ent.Status then
		ply:ChatPrint("You switch the power on.")
	elseif ent.Status then
		ply:ChatPrint("You switch the power off.")
	end
	
	ent:TogglePower()
end
net.Receive( "togglesolgen_stream", ENT.TogglePowerNet )

function ENT.Repair()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	ply:SelectWeapon("gmod_rp_hands")
	ply:SetMoveType(MOVETYPE_NONE)
	ent.Repairing = ply
	
	net.Start("startProgressBar")
		net.WriteDouble(200 - ent:Health())
	net.Send(ply)
	
	timer.Create( ply:UniqueID().."_repair_"..tostring(ent), 0.25, (200 - ent:Health())*4, function()
		ply:SelectWeapon("gmod_rp_hands")
		if (not ent:IsValid()) or (not ply:Alive()) then
			ply:SetMoveType(MOVETYPE_WALK)
			net.Start("stopProgressBar")
			net.Send(ply)
			ent.Repairing = nil
			if ent:IsValid() then 
				timer.Stop(ply:UniqueID().."_repair_"..tostring(ent))
			end
			return
		end
	end )
end
net.Receive( "repsolgen_stream", ENT.Repair )

function ENT:Think()
	if self.Repairing then
		self:SetHealth(self:Health() + 1)
		
		if self:Health() >= 200 then
			self.Repairing:ChatPrint("You finish repairing the generator.")
			
			self.Repairing:SetMoveType(MOVETYPE_WALK)
			net.Start("stopProgressBar")
			net.Send(self.Repairing)
			if self:IsValid() then 
				timer.Stop(self.Repairing:UniqueID().."_repair_"..tostring(self))
			end
			self.Repairing = nil
			self.BlockF2 = false
		end
	end
	
	if self.Status and (not self:IsOutside()) then
		self:TogglePower()
	end
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:OnRemove()
	self:PowerUnLink()
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
