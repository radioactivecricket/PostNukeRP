AddCSLuaFile()

ENT.Base 			= "base_nextbot"
--ENT.Base 			= "base_entity"
ENT.PrintName		= "Zombie Classic"
ENT.Author			= "Eldar Storm"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.RenderGroup		= RENDERGROUP_BOTH
ENT.Spawnable		= true

function ENT:Initialize()
end

if ( SERVER ) then

	ENT.Type = "nextbot"

else

	ENT.Type = "anim"

end