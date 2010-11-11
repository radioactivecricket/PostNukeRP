include('shared.lua')

SWEP.PrintName			= "SMG-LOST"			
SWEP.Slot				= 2
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= false
SWEP.WepSelectIcon		= nil

-- This is the font that's used to draw the firemod icons
SWEP.IconLetter = "/"
	
function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)

	draw.SimpleText(self.IconLetter, "HL2MPTypeDeath", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)
	-- Draw a CS:S select icon

	self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	-- Print weapon information
end
