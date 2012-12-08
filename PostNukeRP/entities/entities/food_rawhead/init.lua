AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/weapons/w_bugbait.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_bugbait.mdl")
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
			
			activator:GiveHunger( 15 )
			local shouldpoison = math.random(1, 100)
			if shouldpoison < 20 then
				local timerstring = tostring(activator:UniqueID())..tostring(self.Entity:EntIndex())
				
				timer.Create("poison"..timerstring, 1, 10, function() 
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
