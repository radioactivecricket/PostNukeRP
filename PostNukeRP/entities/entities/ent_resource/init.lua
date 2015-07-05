AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.AddNetworkString("stopProgressBar")

function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:GetPhysicsObject():EnableMotion(false)
	self.Entity:PhysWake()
	self.resType = nil
	self.amount = nil
end

function ENT:Use( activator, caller )
	if not self.resType then return end
	if not self.amount then return end
	if not activator:KeyPressed( IN_USE ) then return end
	
	if activator.scavving == self then
		timer.Destroy(activator:UniqueID().."_respile_"..tostring(self:EntIndex()))
		timer.Destroy(activator:UniqueID().."_respile_"..tostring(self:EntIndex()).."_end")
		
		activator:SetMoveType(MOVETYPE_WALK)
		activator.scavving = nil
		net.Start("stopProgressBar")
		net.Send(activator)
		return
	elseif activator.scavving then
		return end
	
	activator:SelectWeapon("weapon_simplekeys")
	activator:SetMoveType(MOVETYPE_NONE)
	activator.scavving = self
	
	activator:EmitSound(Sound("ambient/levels/streetwar/building_rubble"..tostring(math.random(1,5))..".wav"))
	
	net.Start("startProgressBar")
		net.WriteDouble(3)
	net.Send(activator)
	
	local respile = self
	timer.Create( activator:UniqueID().."_respile_"..tostring(self:EntIndex()), 0.25, 12, function()
			activator:SelectWeapon("weapon_simplekeys")
			if (not respile:IsValid()) or (not activator:Alive()) then
				activator:SetMoveType(MOVETYPE_WALK)
				net.Start("stopProgressBar")
				net.Send(activator)
				activator.scavving = nil
				if respile:IsValid() then 
					timer.Stop(activator:UniqueID().."_respile_"..tostring(respile:EntIndex()))
				end
				return
			end
			
			
		end )
	local myself = self
	timer.Create( activator:UniqueID().."_respile_"..tostring(self:EntIndex()).."_end", 3, 1, function() 
			net.Start("stopProgressBar")
			net.Send(activator)
			-- ply:Freeze(false)
			activator:SetMoveType(MOVETYPE_WALK)
			activator.scavving = nil
			
			if respile and IsValid(respile) and activator and IsValid(activator) and activator:IsPlayer() then
				respile.amount = respile.amount - 1
				
				local Chance = 50
				local itemChance = 10
				local MinAmount = 1
				local MaxAmount = 3
				
				if activator:Team() == TEAM_SCAVENGER then
					Chance = 75
					itemChance = 15
					MaxAmount = 6
				 end
				 
				if activator:GetSkill("Scavenging") > 0 then
					Chance = Chance + (activator:GetSkill("Scavenging") * 5)
					itemChance = itemChance + (activator:GetSkill("Scavenging") * 2)
					MaxAmount = MaxAmount + activator:GetSkill("Scavenging")
				end
				
				local num = math.random(1,100)
				
				if num < itemChance then
					local scavitmsTotal = 0
					local scavitmsTbl = {}
					for k, v in pairs(PNRP.ScavItems) do
						scavitmsTotal = scavitmsTotal + v
					end
					
					local current = 0
					for k,v in pairs(PNRP.ScavItems) do
						scavitmsTbl[k] = {}
						scavitmsTbl[k].minimum = current
						scavitmsTbl[k].maximum = current + ( (v / scavitmsTotal) * 100 )
						current = current + ( (v / scavitmsTotal) * 100 )
					end
					
					local rndItem = math.random(1,100)
					for k, v in pairs(scavitmsTbl) do
						if rndItem > v.minimum and rndItem <= v.maximum then
							PNRP.Items[k].Create(activator, PNRP.Items[k].Ent, myself:GetPos() + Vector( 0, 0, 20 ) )
							break
						end
					end
				end
				
				if num < Chance then
					local num2 = math.random(MinAmount,MaxAmount)
					activator:EmitSound(Sound("items/ammo_pickup.wav"))
					activator:IncResource(respile.resType, num2)
				end
				
				if respile.amount <= 0 then 
					respile:Remove()
				end
			end
		end )
	
end
