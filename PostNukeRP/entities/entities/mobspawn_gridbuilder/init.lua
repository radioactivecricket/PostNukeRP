AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/props_c17/gravestone004a.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/gravestone004a.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	self.distance = self.Entity:GetNWInt("distance")
	
	self.spwnsRes = self.Entity:GetNWBool("spwnsRes")
	self.spwnsAnt = self.Entity:GetNWBool("spwnsAnt")
	self.spwnsZom = self.Entity:GetNWBool("spwnsZom")
	
	self.infMound = self.Entity:GetNWBool("infMound")
	self.infIndoor = self.Entity:GetNWBool("infIndoor")
	self.infLinked = self.Entity:GetNWEntity("infLinked")
end
	
function ENT:KeyValue (key, value)
	self[key] = tonumber(value) or value
	self.Entity:SetNWString (key, value)
	print ("["..key.." = "..value.."] ")
end

