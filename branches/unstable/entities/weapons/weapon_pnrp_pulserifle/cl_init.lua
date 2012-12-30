include('shared.lua')

SWEP.PrintName			= "PAR-Pulse Rifle"			
SWEP.Slot				= 2
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= false
SWEP.WepSelectIcon		= nil

-- This is the font that's used to draw the firemod icons
SWEP.IconLetter = "2"
	
function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)

	self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	-- Print weapon information
	
	draw.SimpleText(self.IconLetter, "HL2MPTypeDeath", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)
	-- Draw a CS:S select icon

end
