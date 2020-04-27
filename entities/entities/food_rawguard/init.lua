AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/gibs/antlion_gib_large_3.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/gibs/antlion_gib_large_3.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:PhysWake()
end

function ENT:Use( activator, caller )
	
 
	if ( activator:IsPlayer() ) then
		
		local hunger = activator:GetTable().Hunger
		
		if not ( hunger == 100 ) then
			local sound = Sound("npc/ichthyosaur/snap.wav")
			self.Entity:EmitSound( sound )
			
			activator:GiveHunger( 20 )
			
			local health = activator:Health()
		
			if not ( health == activator:GetMaxHealth() ) then
				activator:SetHealth( health + 5 )
				if ( activator:GetMaxHealth() < health + 5  ) then
					activator:SetHealth( activator:GetMaxHealth() )
				end
			end
			
			local shouldpoison = math.random(1, 100)
			if shouldpoison < 20 then
				local timerstring = tostring(activator:UniqueID())..tostring(self.Entity:EntIndex())
				
				timer.Create("poison"..timerstring, 1, 20, function() 
						if activator and IsValid(activator) then
							if not activator:Alive() then
								timer.Destroy("poison"..timerstring)
								return
							end
							activator:TakeDamage( 1, activator, activator)
						end
					end)
			end
			self.Entity:Remove()
		end
	end
 
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
