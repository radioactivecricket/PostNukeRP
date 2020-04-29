AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("")

function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:GetPhysicsObject():EnableMotion(false)
	self.Entity:PhysWake()
	
	self.resource = nil
end

function ENT:Use( activator, caller )
	--	if p:HasInInventory("tool_coffeepot") then
	if not activator:KeyPressed( IN_USE ) then return end
	
	if activator:HasInInventory("tool_toolbox") then
		if self.resource then
			if activator.scavving == self then
				timer.Destroy(activator:UniqueID().."_salvhull_"..tostring(self:EntIndex()))
				timer.Destroy(activator:UniqueID().."_salvhull_"..tostring(self:EntIndex()).."_end")
				
				activator:SetMoveType(MOVETYPE_WALK)
				activator.scavving = nil
				net.Start("stopProgressBar")
				net.Send(activator)
				return
			elseif activator.scavving then
				return end
		
			net.Start( "pnrp_OpenHullRecCh" )
				net.WriteEntity(self)
				net.WriteDouble(tonumber(self.amount))
				net.WriteString(tostring(self.hasScav))
			net.Send(activator)
		else			
			local vehicles = {}
			for k, v in pairs(PNRP.Items) do
				local skin = v["HullSkin"]
				if not skin then skin = 0 end
				if tostring(self:GetModel()) == v["Hull"] and tonumber(self:GetSkin()) == skin then
					table.insert(vehicles, k)
				end
			end
			
			local plyInv = PNRP.GetFullInventorySimple( activator )
			
			net.Start( "pnrp_OpenBuildACarMenu" )
				net.WriteEntity(self)
				net.WriteTable(vehicles)
				net.WriteTable(plyInv)
			net.Send(activator)
		end
	else
		activator:ChatPrint("You will need a toolbox for this.")
	end
end
util.AddNetworkString( "pnrp_OpenHullRecCh" )
util.AddNetworkString( "pnrp_OpenBuildACarMenu" )

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
