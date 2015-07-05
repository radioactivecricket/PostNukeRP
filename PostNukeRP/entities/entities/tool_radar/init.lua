AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.PrecacheModel ("models/props_mining/antlion_detector.mdl")

function ENT:Initialize()	
	self:SetModel("models/props_mining/antlion_detector.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetHealth( 200 )
	self.moveActive = true
	self:PhysWake()
	self:GetPhysicsObject():Wake()
	self.playbackRate = 0
	self.SyncTime = self:GetNetVar("SyncTime", 30)
	self.PlayerENT = nil
	self.Enabled = self:GetNetVar("Enabled", false)
	self.GPRENT = nil
	self.EnabledGPR = self:GetNetVar("EnabledGPR", false)
	self.Status = self:GetNetVar("Status", 0)
	--Status Options
	-- -2 = Dead
	-- -1 = No Power
	--  0 = None (Off)
	--  1 = On/Standby
	--  2 = Synching
	--  3 = In Use/Working/Runing/Whatever
	
	-- Important power vars!
	self.PowerItem = true
	self.PowerLevel = 0
	self.NetworkContainer = nil
	self.LinkedItems = {}
	self.DirectLinks = {}
	
	local Radar_Sound = Sound("plats/tram_move.wav")
	self.RadarAmb = CreateSound(self, Radar_Sound )
	
	self:NextThink(CurTime() + 1.0)
	
	self.PowerUsage = -50
	self:SetNetVar("PowerUsage", self.PowerUsage)
end

function ENT:Use( activator, caller )
	if activator:KeyPressed( IN_USE ) then
		local allowedtouse = false
		local foundGPR = false

		RADAR_FixPlayer(activator, self)
		
		if activator:IsAdmin() and getServerSetting("adminTouchAll") == 1 then 
			activator:ChatPrint("Admin Overide.")
			allowedtouse = true
		else
			if activator:Team() ~= TEAM_WASTELANDER then
				activator:ChatPrint("You don't have any idea how to use this.")
				return
			end
			
			if not self.entOwner then
				self.entOwner = activator
				allowedtouse = true
			else
				if self.entOwner == activator then
					allowedtouse = true
				end
			end
		end
				
		if allowedtouse then
			
			net.Start("radar_menu")
				net.WriteDouble(self:Health())
				net.WriteDouble(self:EntIndex())
				net.WriteEntity(self)
				net.WriteDouble(self.SyncTime)
			net.Send(activator)
		end
		
	end
end
util.AddNetworkString("radar_menu")

--Fixes DySych Issues
function RADAR_FixPlayer(ply, ent)
	local plyRadarIndex = ply.RadarENTIndex
	local foundRadar = false
	
	local foundRadars = ents.FindByClass("tool_radar")
	for k, v in pairs(foundRadars) do
		if v:EntIndex() == plyRadarIndex then
			foundRadar = true
		end
	end
	
	if ent:EntIndex() == ply.RadarENTIndex then
		if ent.Status < 1 then
			foundRadar = false
		end
	end
	
	if not foundRadar then
		ply.RadarENT = nil
		ply.RadarENTIndex = nil
		ply:SetNetVar("RadarENTIndex", nil)
		ply:SetNetVar("RadarENT", nil)
	end
end

function RADAR_Attach()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	if ent.Status < 0 then
		ply:ChatPrint("Unit is dissabled")
		return
	end
	
	ent:GetPhysicsObject():EnableMotion(false)
	ent.moveActive = false
	
	ply.RadarENT = ent
	ply:SetNetVar("RadarENT", ent)
	ply.RadarENTIndex = ent:EntIndex()
	ply:SetNetVar("RadarENTIndex", ent:EntIndex())
	ent.PlayerENT = ply
		
	ent.PowerLevel = -50
	if IsValid(ent.NetworkContainer) then
		ent.NetworkContainer:UpdatePower()
	end
	
	if ent.Status == 0 then 
		ent.Status = 1
		ent:SetNetVar("Status", 1)
	end

end
util.AddNetworkString("RADAR_Attach")
net.Receive( "RADAR_Attach", RADAR_Attach )

function RADAR_Detach()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	RADAR_DoDetach(ply, ent)
end
function RADAR_DoDetach(ply, ent)
	ply.RadarENT = nil
	ply.RadarENTIndex = nil
	ply:SetNetVar("RadarENTIndex", 0)
	ply:SetNetVar("RadarENT", ply)
	ent.PlayerENT = nil
--	ent.Status = 0
--	ent:SetNWString("Status", 0)
end
util.AddNetworkString("RADAR_Detach")
net.Receive( "RADAR_Detach", RADAR_Detach )

function RADAR_AttachGPR()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	local nearbyEnts = ents.FindInSphere(ent:GetPos(), 150)
				
	local gprENT
	local dist = 500
	
	for k, v in pairs(nearbyEnts) do
		if v:GetClass() == "tool_gpr" and !v.Charging and (not IsValid(v.NetworkContainer)) then
			if ent:GetPos():Distance(v:GetPos()) < dist then
				gprENT = v
				dist = ent:GetPos():Distance(v:GetPos())
			end
		end
	end
	
	if IsValid(gprENT) then
		gprENT:SetPos(util.LocalToWorld( ent, Vector(25, 5, 60)))
		gprENT:SetAngles(ent:GetAngles()+Angle(0,0,0))
		
		constraint.Weld(ent, gprENT, 0, 0, 0, true)
		
		ent:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
		ply:ChatPrint("You've hooked the GPR.")
		
		ent.GPRENT = gprENT
		ent.EnabledGPR = true
		ent:SetNetVar("EnabledGPR", true)
		
		ent.PowerLevel = -60
		if IsValid(ent.NetworkContainer) then
			ent.NetworkContainer:UpdatePower()
		end
		
		gprENT:GetPhysicsObject():EnableMotion(false)
		ent.moveActive = false
	else
		ply:ChatPrint("No nearby GPR.")
	end

end
util.AddNetworkString("RADAR_AttachGPR")
net.Receive( "RADAR_AttachGPR", RADAR_AttachGPR )

function RADAR_RemoveGPR()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	RADAR_DetachGPR(ent)
end
function RADAR_DetachGPR(ent)
	local gprENT = ent.GPRENT
	if IsValid(gprENT) then
		constraint.RemoveConstraints( gprENT, "Weld" )
		gprENT:GetPhysicsObject():Wake()
		gprENT:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
		
		if ent.PowerLevel ==  -60 then
			ent.PowerLevel = -50
			if IsValid(ent.NetworkContainer) then
				ent.NetworkContainer:UpdatePower()
			end
		end
		
		gprENT:GetPhysicsObject():EnableMotion(true)
		gprENT.moveActive = true
		gprENT:GetPhysicsObject():Wake()
	end
	ent.GPRENT = nil
	ent.EnabledGPR = false
	ent:SetNetVar("EnabledGPR", false)
end
util.AddNetworkString("RADAR_RemoveGPR")
net.Receive( "RADAR_RemoveGPR", RADAR_RemoveGPR )

function RADAR_Synch()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	if ent.Status < 0 then
		ply:ChatPrint("Unit is dissabled")
		return
	end
	
	ent.Status = 2
	ent:SetNetVar("Status", 2)
	
	ply:ChatPrint("Syncing Radar...")
	--Keeps radar from beeing moved.
	ent.moveActive = false
	ent:DoFreeze()
	
	ent.RadarAmb:Play()
	ent.playbackRate = 0.1
	ent.Entity:SetPlaybackRate(ent.playbackRate)
	ent.RadarAmb:ChangePitch( 20, 10 )
	ent.RadarAmb:ChangeVolume( 50, 10 )
		
	timer.Simple( ent.SyncTime, function ()
		
		ply:ChatPrint("Sync complete!")
		
		ent.Status = 3
		ent:SetNetVar("Status", 3)
		
		ent.BlockF2 = true
		
	end )
end
util.AddNetworkString("RADAR_Synch")
net.Receive( "RADAR_Synch", RADAR_Synch )

function RADAR_Repair()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	local amount = 200 - ent:Health()
	
	ply:Freeze(true)
	ply:ChatPrint("Fixing Radar...")
	
	timer.Simple( amount/10, function ()
		ply:Freeze(false)
		
		ent:SetHealth( 200 )
		
		if ent:Health() > 200 then ent:SetHealth( 200 ) end
		
		ply:ChatPrint("Repair compleate!")
		
		ent.Status = 0
		ent:SetNetVar("Status", 0)
		
	end )
end
util.AddNetworkString("RADAR_Repair")
net.Receive( "RADAR_Repair", RADAR_Repair )

function RADAR_PowerOff()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	if ent.PlayerENT then
		ent.PlayerENT:ChatPrint("Radar Shutdown...")
	else
		ply:ChatPrint("Radar Shutdown...")
	end
	RADAR_Shutdown(ent)
end
util.AddNetworkString("RADAR_PowerOff")
net.Receive( "RADAR_PowerOff", RADAR_PowerOff )

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() <= 0 then --run on death
		self:SetHealth( 0 )
		
		RADAR_Shutdown(self)
		RADAR_DetachGPR(self)
	end
end 

function RADAR_Shutdown(ent)
	ent.Enabled = false
	ent:SetNetVar("Enabled", false)
	
	if IsValid(ent.PlayerENT) then
		local ply = ent.PlayerENT
		ply:ChatPrint("Radar signal lost.")
		RADAR_DoDetach(ply, ent)
	end
	ent.RadarAmb:Stop()
	ent.PlayerENT = nil
	RADAR_DetachGPR(ent)
	ent.GPRENT = nil
	
	ent.Status = 0
	ent:SetNetVar("Status", 0)
	
	ent:GetPhysicsObject():EnableMotion(true)
	ent.moveActive = true
	ent:GetPhysicsObject():Wake()
	
	ent.BlockF2 = false
	
	ent.PowerLevel = 0
	if IsValid(ent.NetworkContainer) then
		ent.NetworkContainer:UpdatePower()
	end
end

function ENT:Think()
	if not self.SynchedPlayer and self.Enabled then
		RADAR_Shutdown(self)
		return
	end
	
	if self.Status > 0 then
		if not self:IsOutside() then
			RADAR_Shutdown(self)
		end
	end
	
	if self:Health() < 150 then
		local effectdata = EffectData()
		local rndGen = math.random(10)
		
		if rndGen == 5 then
			effectdata:SetStart( self:LocalToWorld( Vector( 0, 0, 10 ) ) ) 
			effectdata:SetOrigin( self:LocalToWorld( Vector( 0, 0, 10 ) ) )
			effectdata:SetNormal( Vector(0,0,1) )
			effectdata:SetScale( 0.7 )
			util.Effect( "ManhackSparks", effectdata )
			self:EmitSound("ambient/levels/labs/electric_explosion5.wav", 100, 100 )
		end
	end
	
	if IsValid(self.GPRENT) then
		local GPRCheck = false
		
		local findRADHost = constraint.FindConstraints( self.GPRENT, "Weld" )
		for _, v in pairs(findRADHost) do
			if v.Entity[1].Entity == self then
				GPRCheck = true
			end
		end
		
		if not GPRCheck then
			self.GPRENT:SetPos(util.LocalToWorld( self, Vector(25, 5, 60)))
			self.GPRENT:SetAngles(self:GetAngles()+Angle(0,0,0))
				
			constraint.Weld(self, self.GPRENT, 0, 0, 0, true)
				
			self:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
			
			GPRCheck = true
		end
	elseif self.EnabledGPR then
		RADAR_DetachGPR(self)
	end
	
	if (not self.NetworkContainer) or (not self.NetworkContainer.NetPower) or self.NetworkContainer.NetPower < 0 then
		RADAR_Shutdown(self)
	end
	
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:DoFreeze()
	self:GetPhysicsObject():EnableMotion(false)
end

function ENT:DoUnFreeze()
	self:GetPhysicsObject():EnableMotion(true)
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end

function ENT:OnRemove()
	RADAR_Shutdown(self)
	self:PowerUnLink()
end
