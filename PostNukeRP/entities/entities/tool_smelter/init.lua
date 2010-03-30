AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/props_forest/furnace01.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props_forest/furnace01.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:PhysWake()
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		if activator:KeyPressed( IN_USE ) then
			local rp = RecipientFilter()
			rp:RemoveAllPlayers()
			rp:AddPlayer( activator )
			 
			umsg.Start("smelt_menu", rp)
			umsg.End()
		end
	end
end

function DoSmelt( pl, handler, id, encoded, decoded )
	local smallparts = tonumber(decoded[1])
	local chems = math.Round(smallparts / 2)
	
	if pl:Team() ~= 3 then
		pl:ChatPrint( "You must be a scientist to use a smelter!" )
		return
	end
	
	if pl:GetResource( "Small_Parts" ) < smallparts then
		pl:ChatPrint( "Not enough small parts to do this!" )
		return
	end
	if pl:GetResource( "Chemicals" ) < chems then
		pl:ChatPrint( "Not enough chemicals to do this!" )
		return
	end
	
	local amount = math.Round(smallparts / 2)
	--pl:SetResource( "Small_Parts", pl:GetResource( "Small_Parts") - smallparts )
	pl:DecResource( "Small_Parts", smallparts )
	pl:DecResource( "Chemicals", chems )
	pl:IncResource( "Scrap", amount )
	
	pl:ChatPrint( "You have smelted "..tostring(smallparts).." Small Parts and "..tostring(chems).." Chemicals into "..tostring(amount).." Scrap!" )
end
datastream.Hook( "smelt_stream", DoSmelt )

