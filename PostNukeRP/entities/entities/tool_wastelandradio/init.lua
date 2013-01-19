AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.AddNetworkString("OpenRadioStations")
util.AddNetworkString("Read_Paper")

util.PrecacheModel ("models/props_lab/citizenradio.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props_lab/citizenradio.mdl")
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	self.pid = self.Entity:GetNWString("Owner_UID")
	self.name = self.Entity:GetNWString("name", "")
	self.text = self.Entity:GetNWString("text", "")
		
	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	self:GetPhysicsObject():Wake()
	
	self.File = ""
	self.Volume = 0.5
	self.soundlevel = 60
	self.FM = 101.9
	self.Enabled = true
	self.Playing = false
	
	self.stations = {}
	for k, v in pairs(file.Find("sound/music/*", "GAME" )) do
		self.stations[v] = k
	--	table.insert(self.stations,v)
	end
	
	-- Important power vars!
	self.PowerItem = true
	self.PowerLevel = 0
	self.NetworkContainer = nil
	self.LinkedItems = {}
	self.DirectLinks = {}
	
	self.PowerUsage = -5
	self.Entity:SetNWString("PowerUsage", self.PowerUsage)
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		if activator:KeyPressed( IN_USE ) then
			local radioInfo = {}
			radioInfo["Title"] = self.File
			radioInfo["FM"] = self.FM
			radioInfo["Volume"] = self.Volume
			radioInfo["SoundLevel"] = self.soundlevel
			radioInfo["IsOn"] = self.Enabled
			net.Start("OpenRadioStations")
				net.WriteEntity(self)
				net.WriteTable(radioInfo)
			net.Send(activator)
		end
	end
end

function WR_setRadoFM( )
	local ply = net.ReadEntity()
	local radioENT = net.ReadEntity()
	local FM = net.ReadDouble()
	
	radioENT.FM = round(FM, 1)
	if radioENT.MusicAmb then
		radioENT.MusicAmb:Stop()
	end
end
util.AddNetworkString("setRadoFM")
net.Receive( "setRadoFM", WR_setRadoFM )

function WR_setRadioVolume( )
	local ply = net.ReadEntity()
	local radioENT = net.ReadEntity()
	local Vol = net.ReadDouble()
	
	radioENT.Volume = Vol
	if radioENT.MusicAmb then
		radioENT.MusicAmb:ChangeVolume( Vol, 1 )
	end
end
util.AddNetworkString("setRadioVol")
net.Receive( "setRadioVol", WR_setRadioVolume )

function WR_setRadioSoundLevel( )
	local ply = net.ReadEntity()
	local radioENT = net.ReadEntity()
	local SL = net.ReadDouble()
	
	radioENT.soundlevel = SL
	if radioENT.MusicAmb then
		radioENT.MusicAmb:SetSoundLevel( SL )
	end
end
util.AddNetworkString("setRadioSL")
net.Receive( "setRadioSL", WR_setRadioSoundLevel )

function WR_On( )
	local ply = net.ReadEntity()
	local radioENT = net.ReadEntity()
	
	radioENT.PowerLevel = radioENT.PowerUsage
	if IsValid(radioENT.NetworkContainer) then
		radioENT.NetworkContainer:UpdatePower()
	end
	
	radioENT.Enabled = true
	
	if radioENT.MusicAmb then
		radioENT.MusicAmb:SetSoundLevel(radioENT.soundlevel)
		if radioENT.File != "" then
			radioENT.MusicAmb:Play()
		end
		radioENT.MusicAmb:ChangeVolume( radioENT.Volume, 0 )
	end
end
util.AddNetworkString("WR_On")
net.Receive( "WR_On", WR_On )

function WR_Off( )
	local ply = net.ReadEntity()
	local radioENT = net.ReadEntity()
	
	WR_TurnOff(radioENT)
end
util.AddNetworkString("WR_Off")
net.Receive( "WR_Off", WR_Off )

function WR_TurnOff(ent)
	ent.Enabled = false
	if ent.MusicAmb then
		ent.MusicAmb:Stop()
	end
	
	ent.PowerLevel = 0
	if IsValid(ent.NetworkContainer) then
		ent.NetworkContainer:UpdatePower()
	end
end

function ENT:Think()
	if (not self.NetworkContainer) or (not self.NetworkContainer.NetPower) or self.NetworkContainer.NetPower < 0 then
		WR_TurnOff(self)
	end
end

function ENT:OnRemove()
	if self.MusicAmb then
		self.MusicAmb:Stop()
	end
	self:PowerUnLink()
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end

