AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.AddNetworkString("OpenTransMainMenu")

util.PrecacheModel ("models/props_lab/workspace003.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props_lab/workspace003.mdl")
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	self.pid = self.Entity:GetNWString("Owner_UID")
	self.name = self.Entity:GetNWString("name", "")
		
	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	self:GetPhysicsObject():Wake()
	
	self.Enabled = false
	
	self.File = ""
	self.Volume = 1.0
	self.soundlevel = 80
	self.FM = 101.9
	self.playing = false
	self.Track = self.Entity:GetNWString("Track", 0)
	
	self.PlayList = {}
	
	self.stations = {}
	for k, v in pairs(file.Find("sound/music/*", "GAME" )) do
		self.stations[v] = SoundDuration( "music/"..v ) * 2
	end
	
	-- Important power vars!
	self.PowerItem = true
	self.PowerLevel = 0
	self.NetworkContainer = nil
	self.LinkedItems = {}
	self.DirectLinks = {}
	
	self.PowerUsage = -200
	self.Entity:SetNWString("PowerUsage", self.PowerUsage)	
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		if activator:KeyPressed( IN_USE ) then
			if not self.PlayList then self.PlayList = { } end
			local transInfo = {}
			transInfo["isOn"] = self.Enabled
			transInfo["file"] = self.File
			transInfo["playing"] = self.playing
			transInfo["pause"] = self.pause
			transInfo["FM"] = self.FM
			transInfo["Track"] = self.Track
			net.Start("OpenTransMainMenu")
				net.WriteEntity(self)
				net.WriteTable(self.stations)
				net.WriteTable(self.PlayList)
				net.WriteTable(transInfo)
			net.Send(activator)
		end
	end
end

function WR_FMTogglePower(transENT)
	local ply = net.ReadEntity()
	local transENT = net.ReadEntity()
	
	if transENT.Enabled then
		WR_PowerFMOff(transENT)
		ply:ChatPrint("Transmitter Off")
	else
		transENT.Enabled = true
		ply:ChatPrint("Transmitter On")
		
		transENT.PowerLevel = transENT.PowerUsage
		if IsValid(transENT.NetworkContainer) then
			transENT.NetworkContainer:UpdatePower()
		end
	end
end
util.AddNetworkString("WR_FMTogglePower")
net.Receive( "WR_FMTogglePower", WR_FMTogglePower )

function WR_PowerFMOff(transENT)
	WR_FMHalt(transENT)
	transENT.Enabled = false
	
	transENT.PowerLevel = 0
	if IsValid(transENT.NetworkContainer) then
		transENT.NetworkContainer:UpdatePower()
	end
end

--Updates the playlist every time someone changes it in derma
function WR_FMUpdatePlaylist( )
	local ply = net.ReadEntity()
	local transENT = net.ReadEntity()
	local playList = net.ReadTable()
	
	transENT.PlayList = playList
end
util.AddNetworkString("WR_FMUpdatePlaylist")
net.Receive( "WR_FMUpdatePlaylist", WR_FMUpdatePlaylist )

function WR_FMResetPlaylist( )
	local ply = net.ReadEntity()
	local transENT = net.ReadEntity()
	
	WR_FMHalt(transENT)
	transENT.PlayList = {}
end
util.AddNetworkString("WR_FMResetPlaylist")
net.Receive( "WR_FMResetPlaylist", WR_FMResetPlaylist )

function WR_DelTrack(transENT)
	local playlist = transENT.PlayList
	if not playlist or table.Count(playlist) < 1 then
		return
	end
	table.remove(playlist, 1)
	
	transENT.PlayList = playlist
end

function WR_FMToggleTreansmit()
	local ply = net.ReadEntity()
	local transENT = net.ReadEntity()
	
	if transENT.playing then
		WR_FMStop(transENT)
	else
		WR_FMTransmit( ply, transENT )
	end
end
util.AddNetworkString("WR_FMToggleTreansmit")
net.Receive( "WR_FMToggleTreansmit", WR_FMToggleTreansmit )

--Starts the Transmitter
function WR_FMTransmit( ply, transENT )
	local playlist = transENT.PlayList
	if not playlist or table.Count(playlist) < 1 then
		ply:ChatPrint("Playlist is empty")
		WR_FMHalt( transENT )
		return
	end
	local duration = round(playlist[1][3], 2)
	if timer.Exists("FM_"..tostring(transENT)) then
		timer.Destroy("FM_"..tostring(transENT))
	end
	
	if not transENT.Enabled then
		ply:ChatPrint("Transmitter is off")
		WR_FMHalt( transENT )
		return
	end
	
	if WR_CheckDupChannels( transENT, transENT.FM ) then 
		ply:ChatPrint("There is allready a Transmitter on this channel")
		return
	end
	
	WR_PlayNextTrack( transENT )

	duration = duration + 1
	timer.Create("FM_"..tostring(transENT), duration, 1, function() 
		WR_FMTimer( transENT ) 
	end)
end

function WR_FMTimer( transENT )
	local playlist = transENT.PlayList
	WR_FMFade( transENT )
	timer.Create("FM_FADE_"..tostring(transENT), 2, 1, function() 
		WR_FMStop( transENT )
		WR_DelTrack(transENT)
		if not playlist or table.Count(playlist) < 1 then
			WR_FMHalt( transENT )
			return
		end

		WR_PlayNextTrack( transENT )
		duration = round(playlist[1][3],2)
		duration = duration + 1
		timer.Adjust("FM_"..tostring(transENT),duration, 1, function() WR_FMTimer( transENT ) end)
		timer.Start("FM_"..tostring(transENT))
		timer.Destroy("FM_FADE_"..tostring(transENT))
	end)
end

function WR_FMNextTrack()
	local ply = net.ReadEntity()
	local transENT = net.ReadEntity()
	
	WR_FMTimer( transENT )
end
util.AddNetworkString("WR_FMNextTrack")
net.Receive( "WR_FMNextTrack", WR_FMNextTrack )

function WR_PlayNextTrack( transENT )
	if not transENT.Enabled then
		WR_FMHalt( transENT )
		return
	end
	local playlist = transENT.PlayList
	if not playlist or table.Count(playlist) < 1 then
		WR_FMHalt( transENT )
		return
	end
	
	local file = playlist[1][2]
	local Soundfile = Sound("music/"..file)
	transENT.File = Soundfile
	transENT.Track = playlist[1][1]
	transENT.Entity:SetNWString("Track", playlist[1][1])
	local setname = string.sub(file,0,-5)
	local foundRadios = ents.FindByClass("tool_wastelandradio")
	for k, v in pairs(foundRadios) do
		if tostring(v.FM) == tostring(transENT.FM) then
			if v.Enabled then
				if v.MusicAmb then
					v.MusicAmb:Stop()
				end
				v.MusicAmb = CreateSound(v.Entity, Soundfile )
				v.File = setname
				v.MusicAmb:SetSoundLevel(v.soundlevel)
				v.MusicAmb:Play()
				v.MusicAmb:ChangeVolume(v.Volume, 0)
				v.Playing = true
			end
		end
	end
	transENT.playing = true
end

--Checks for others on the same channel
function WR_CheckDupChannels( transENT, channel )
	local foundFM = ents.FindByClass("tool_wastelandtransmitter")
	for k, v in pairs(foundFM) do
		if v.FM == channel and v ~= transENT then return true	end
	end
	
	return false
end

--This acually stops the playlist
function WR_FMSetChannel( )
	local ply = net.ReadEntity()
	local transENT = net.ReadEntity()
	local FM = net.ReadDouble()
	FM = round(FM, 2)
	if WR_CheckDupChannels( transENT, FM ) then 
		ply:ChatPrint("There is allready a Transmitter on this channel")
		return
	end
	if transENT.playing then
		WR_FMStop(transENT)
	end
	transENT.FM = FM
	print(tostring(transENT).." "..FM)
end
util.AddNetworkString("WR_FMSetChannel")
net.Receive( "WR_FMSetChannel", WR_FMSetChannel )

function WR_FMFade(transENT)
	local foundRadios = ents.FindByClass("tool_wastelandradio")
	for k, v in pairs(foundRadios) do
		if tostring(v.FM) == tostring(transENT.FM) then
			if v.MusicAmb then
				v.MusicAmb:FadeOut( 2 )
			end
		end
	end
end

function WR_FMStop(transENT)
	local foundRadios = ents.FindByClass("tool_wastelandradio")
	for k, v in pairs(foundRadios) do
		if tostring(v.FM) == tostring(transENT.FM) then
			if v.MusicAmb then
				v.MusicAmb:Stop()
				v.File = ""
				v.Playing = false
			end
		end
	end
	transENT.playing = false
	transENT.File = ""
end

function WR_FMHalt(transENT)
	WR_FMStop(transENT)
	if timer.Exists("FM_"..tostring(transENT)) then
		timer.Destroy("FM_"..tostring(transENT))
	end
end

function ENT:Think()
	if (not self.NetworkContainer) or (not self.NetworkContainer.NetPower) or self.NetworkContainer.NetPower < 0 then
		WR_PowerFMOff(self)
	end
end

function ENT:OnRemove()
	self:PowerUnLink()
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
