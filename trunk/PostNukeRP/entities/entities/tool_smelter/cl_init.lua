include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

function SmeltMenu()
	local smallparts = GetResource("Small_Parts")
	
	local w = 200
	local h = 150
	local title = "Smelt Small Parts"

	local smelt_frame = vgui.Create("DFrame")
	--smelt_frame:SetPos( (ScrW()/2) - (w / 2), (ScrH()/2) - (h / 2))
	smelt_frame:Center()
	smelt_frame:SetSize( w, h )
	smelt_frame:SetTitle( title )
	smelt_frame:SetVisible( true )
	smelt_frame:SetDraggable( true )
	smelt_frame:ShowCloseButton( true )
	smelt_frame:MakePopup()
	
	local InfoLabel = vgui.Create( "Label", smelt_frame )
	InfoLabel:SetPos( 10, 30 )
	InfoLabel:SetText(" 2 Small Parts + 1 Chemicals = 1 Scrap")
	InfoLabel:SizeToContents()
	
	local ScrapSlider = vgui.Create( "DNumSlider", smelt_frame )
	ScrapSlider:SetPos( 25, 50 )
	ScrapSlider:SetSize( 150, 100 )
	ScrapSlider:SetText("Small Parts Used")
	ScrapSlider:SetMin( 0 )
	ScrapSlider:SetMax( smallparts )
	ScrapSlider:SetDecimals( 0 )
	
	-- local CreatedLabel = vgui.Create( "Label", smelt_frame )
	-- CreatedLabel:SetPos( 10, 30 )
	-- CreatedLabel:SetText("2 Small Parts + 1 Chemicals = 1 Scrap")
	-- CreatedLabel:SizeToContents()
	
	local SubmitButton = vgui.Create( "DButton" )
	SubmitButton:SetParent( smelt_frame )
	SubmitButton:SetText( "Smelt" )
	SubmitButton:SetPos( 60, 100 )
	--SubmitButton:SetSize( 100, 75 )
	SubmitButton.DoClick = function()
		datastream.StreamToServer( "smelt_stream", { ScrapSlider:GetValue() } )
		smelt_frame:Close()
	end
	
end
usermessage.Hook("smelt_menu", SmeltMenu)

