include('shared.lua')

SWEP.PrintName			= "Precision Rifle"			
SWEP.Slot				= 4
SWEP.SlotPos			= 1
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
	
SWEP.IconLetter = "o"

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)

	self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	-- Print weapon information

	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)
	-- Draw a CS:S select icon

end

-- We need to get these so we can scale everything to the player's current resolution.
local iScreenWidth = surface.ScreenWidth()
local iScreenHeight = surface.ScreenHeight()

local SCOPEFADE_TIME = 0.4
function SWEP:DrawHUD()
	local bScope = self.Weapon:GetDTBool(1)
	if bScope ~= self.bLastScope then -- Are we turning the scope off/on?

		self.bLastScope = bScope
		self.fScopeTime = CurTime()
		
	elseif 	bScope then
	
		local fScopeZoom = self.Weapon:GetNetworkedFloat("ScopeZoom")
		if fScopeZoom ~= self.fLastScopeZoom then -- Are we changing the scope zoom level?
	
			self.fLastScopeZoom = fScopeZoom
			self.fScopeTime = CurTime()
		end
	end
		
	local fScopeTime = self.fScopeTime or 0

	if fScopeTime > CurTime() - SCOPEFADE_TIME then
	
		local Mul = 1.0 -- This scales the alpha
		Mul = 1 - math.Clamp((CurTime() - fScopeTime)/SCOPEFADE_TIME, 0, 1)
	
		surface.SetDrawColor(0, 0, 0, 255*Mul) -- Draw a black rect over everything and scale the alpha for a neat fadein effect
		surface.DrawRect(0,0,iScreenWidth,iScreenHeight)
	end

	if bScope then 

		-- Draw the crosshair
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawLine(self.CrossHairTable.x11, self.CrossHairTable.y11, self.CrossHairTable.x12, self.CrossHairTable.y12)
		surface.DrawLine(self.CrossHairTable.x21, self.CrossHairTable.y21, self.CrossHairTable.x22, self.CrossHairTable.y22)

		-- Put the texture
		surface.SetDrawColor(0, 0, 0, 255)
		surface.SetTexture(surface.GetTextureID("scope/scope_normal"))
		surface.DrawTexturedRect(self.LensTable.x, self.LensTable.y, self.LensTable.w, self.LensTable.h)

		-- Fill in everything else
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(self.QuadTable.x1 - 2.5, self.QuadTable.y1 - 2.5, self.QuadTable.w1 + 5, self.QuadTable.h1 + 5)
		surface.DrawRect(self.QuadTable.x2 - 2.5, self.QuadTable.y2 - 2.5, self.QuadTable.w2 + 5, self.QuadTable.h2 + 5)
		surface.DrawRect(self.QuadTable.x3 - 2.5, self.QuadTable.y3 - 2.5, self.QuadTable.w3 + 5, self.QuadTable.h3 + 5)
		surface.DrawRect(self.QuadTable.x4 - 2.5, self.QuadTable.y4 - 2.5, self.QuadTable.w4 + 5, self.QuadTable.h4 + 5)
	end
end

local IRONSIGHT_TIME = 0.15
