AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.AddNetworkString("Edit_Paper")
util.AddNetworkString("Read_Paper")

util.PrecacheModel ("models/props_c17/paper01.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/paper01.mdl")
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	self.pid = self.Entity:GetNWString("Owner_UID")
	self.name = self.Entity:GetNWString("name", "")
	self.text = self.Entity:GetNWString("text", "")

	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	self:GetPhysicsObject():EnableMotion(false)
	
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		if activator:KeyPressed( IN_USE ) then
			if tostring(self:GetNetworkedString( "Owner_UID" , "None" )) == PNRP:GetUID( activator ) then
				net.Start("Edit_Paper")
					net.WriteEntity(self)
					net.WriteString(self.name)
					net.WriteString(self.text)
				net.Send(activator)
			else
				net.Start("Read_Paper")
					net.WriteEntity(self)
					net.WriteString(self.name)
					net.WriteString(self.text)
				net.Send(activator)
			end
		end
	end
end

function WritePaper( )
	local ply = net.ReadEntity()
	local paperENT = net.ReadEntity()
	local name = net.ReadString()
	local text = net.ReadString()
	paperENT.name = name
	paperENT.text = text
	paperENT:SetNetworkedString("name", name)
	paperENT:SetNetworkedString("text", text)
end
util.AddNetworkString("Write_Paper")
net.Receive( "Write_Paper", WritePaper )

function ViewPaper( )
	local ply = net.ReadEntity()
	local paperENT = net.ReadEntity()
	net.Start("Read_Paper")
		net.WriteEntity(paperENT)
		net.WriteString(paperENT.name)
		net.WriteString(paperENT.text)
	net.Send(ply)
end
util.AddNetworkString("View_Paper")
net.Receive( "View_Paper", ViewPaper )

