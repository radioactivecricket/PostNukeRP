include('shared.lua')

SWEP.PrintName			= "Combat Knife"			
SWEP.Slot				= 1
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.WepSelectIcon		= nil

surface.CreateFont("csd", ScreenScale(60), 500, true, true, "CSSelectIcons")
	
SWEP.IconLetter = "j"

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)

	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)
	-- Draw a CS:S select icon

	self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	-- Print weapon information
end
