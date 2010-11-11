include('shared.lua')

SWEP.PrintName			= "Badlands Rifle"			
SWEP.Slot				= 3
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= false
SWEP.WepSelectIcon		= nil
SWEP.CSMuzzleFlashes	= true

-- This is the font that's used to draw the select icons
surface.CreateFont("csd", ScreenScale(60), 500, true, true, "CSSelectIcons")
	
SWEP.IconLetter = "v"

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)

	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)
	-- Draw a CS:S select icon

	self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	-- Print weapon information
end
