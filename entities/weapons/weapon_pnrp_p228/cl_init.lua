include('shared.lua')

SWEP.PrintName			= "P228"			
SWEP.Slot				= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= false
SWEP.WepSelectIcon		= nil
SWEP.CSMuzzleFlashes	= true

--fntTable = {ScreenScale(60), 500, true, true, "CSSelectIcons"}
fntTable = { 
	font		= "csd", 
	size		= ScreenScale(60),
	weight		= 500,
	antialias	= 1,
	additive	= 1
}
surface.CreateFont("CSSelectIcons", fntTable)
	
SWEP.IconLetter = "y"

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)

	self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	-- Print weapon information

	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)
	-- Draw a CS:S select icon

end
