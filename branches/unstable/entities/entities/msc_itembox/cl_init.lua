include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

function BoxViewCheck()
	local myPlayer = LocalPlayer()
	
	local tracedata = {}
	tracedata.start = myPlayer:GetShootPos()
	tracedata.endpos = tracedata.start + (myPlayer:GetAimVector() * 600)
	tracedata.filter = myPlayer
	local trace = util.TraceLine(tracedata)
	
	if !trace.Entity:IsValid() then return end
	
	if trace.Entity:GetClass() == "msc_itembox" then
		local item = trace.Entity:GetNWString("itemname")
		local amount = trace.Entity:GetNWInt("amount")
		amount = math.Round(amount)
		if (not item) or (not amount) then return end
		
		surface.SetFont("CenterPrintText")
		local tWidth, tHeight = surface.GetTextSize(tostring(amount).." "..item)
		
		-- surface.SetTextColor(Color(255,255,255,255))
		-- surface.SetTextPos(ScrW() / 2, ScrH() / 2)
		-- surface.DrawText( community.." Community Stockpile" )
		draw.WordBox( 8, (ScrW() / 2) - (8 + (tWidth / 2)), (ScrH() / 2) - (16 + tHeight), tostring(amount).." "..item, "CenterPrintText", Color(50,50,75,100), Color(255,255,255,255) )
		
		-- local gridMessage = "Distance:  "..tostring(distance).."\nSpawn Resources:  "..tostring(resources).."\nSpawn Antlions:  "..tostring(antlions).."\nSpawn Zombies:  "..tostring(zombies).."\nCan Make Mounds:  "..tostring(mounds).."\nIs Indoor:  "..tostring(indoor)
		-- AddWorldTip( self.Entity:EntIndex(), gridMessage, 0.5, self.Entity:GetPos(), self.Entity )
	end
end
hook.Add( "HUDPaint", "BoxViewCheck", BoxViewCheck )
