include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end


function PlantMenu( um )
	local fruitLevel = um:ReadShort()
	local plantStatus = um:ReadShort()
	local filtered = um:ReadBool()
	local fertilized = um:ReadBool()
	local airator = um:ReadBool()
	local canPrune = um:ReadBool()
	local plantEnt = um:ReadEntity()
	
	local w = 300
	local h = 400
	local title = "Plant Menu"

	local plant_frame = vgui.Create("DFrame")
	--smelt_frame:SetPos( (ScrW()/2) - (w / 2), (ScrH()/2) - (h / 2))
	plant_frame:SetSize( w, h )
	plant_frame:SetTitle( title )
	plant_frame:SetVisible( true )
	plant_frame:SetDraggable( true )
	plant_frame:ShowCloseButton( true )
	plant_frame:Center()
	plant_frame:MakePopup()
	
--	local FLevelLabel = vgui.Create("Label", plant_frame)
--	FLevelLabel:SetPos(10,25)
--	FLevelLabel:SetText("Fruits on tree:  "..tostring(fruitLevel))
--	FLevelLabel:SizeToContents()
	
--	local StatusLabel = vgui.Create("Label", plant_frame)
--	StatusLabel:SetPos(10,50)
--	StatusLabel:SetText("Plant Status:  "..tostring(plantStatus).."%")
--	StatusLabel:SizeToContents()
	
	local StatusBar = vgui.Create( "DPanel", plant_frame )
		StatusBar:SetPos( 10, 40 )
		StatusBar:SetSize( plant_frame:GetWide() - 20, 20 )
		StatusBar.Paint = function()
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.DrawRect( 0, 0, StatusBar:GetWide(), StatusBar:GetTall() )
			surface.SetDrawColor( 122, 197, 205, 125 )
			surface.DrawRect( 0, 0, StatusBar:GetWide(), StatusBar:GetTall() )
			
			surface.SetDrawColor( 122, 197, 205, 255 )
			surface.DrawOutlinedRect(0, 0, StatusBar:GetWide(), StatusBar:GetTall() )
			
			surface.DrawRect( 0, 0, StatusBar:GetWide() * ( plantStatus / 100 ) , StatusBar:GetTall())
			
			-- surface.SetFont( "HudHintTextLarge" )
			-- surface.SetTextPos( 2, 5 )
			-- surface.SetTextColor( Color( 0, 0, 0, 255 ) )
			-- surface.DrawText( "Respect Level: "..tostring(GetRespectLevel( myRespect )) )
			local StatusLabel = vgui.Create("DLabel", StatusBar)
			StatusLabel:SetPos(5, 3)
			StatusLabel:SetColor( Color( 0, 0, 0, 255 ) )
			StatusLabel:SetText( "Plant Status:" )
			StatusLabel:SizeToContents()
			
			local amtLabel = vgui.Create("DLabel", StatusBar)
			amtLabel:SetColor( Color( 0, 0, 0, 255 ) )
			amtLabel:SetText( tostring(plantStatus).."%" )
			amtLabel:SizeToContents()
			amtLabel:SetPos(StatusBar:GetWide() - 125, 3 )
		end
	
	if filtered then
		local FilterLabel = vgui.Create("Label", plant_frame)
		FilterLabel:SetPos( 25, 75 )
		FilterLabel:SetText( "Water filter already built." )
		FilterLabel:SizeToContents()
	else
		local FilterButton = vgui.Create( "DButton" )
		FilterButton:SetParent( plant_frame )
		FilterButton:SetText( "Build Water Filter" )
		FilterButton:SetPos( 25, 75 )
		FilterButton:SetSize( 125, 30 )
		FilterButton.DoClick = function ()
			datastream.StreamToServer( "addfilter_stream", { plantEnt } )
			plant_frame:Close()
		end
		
		local FilterLabel = vgui.Create("Label", plant_frame)
		FilterLabel:SetPos( 160, 80 )
		FilterLabel:SetText( "20 Small Parts" )
		FilterLabel:SizeToContents()
	end
	
	if fertilized then
		local FertLabel = vgui.Create("Label", plant_frame)
		FertLabel:SetPos( 25, 125 )
		FertLabel:SetText( "Plant already fertilized." )
		FertLabel:SizeToContents()
	else
		local FertButton = vgui.Create( "DButton" )
		FertButton:SetParent( plant_frame )
		FertButton:SetText( "Fertilize Plant" )
		FertButton:SetPos( 25, 125 )
		FertButton:SetSize( 125, 30 )
		FertButton.DoClick = function ()
			datastream.StreamToServer( "fertilize_stream", { plantEnt } )
			plant_frame:Close()
		end
		
		local FertLabel = vgui.Create("Label", plant_frame)
		FertLabel:SetPos( 160, 130 )
		FertLabel:SetText( "5 Chems" )
		FertLabel:SizeToContents()
	end
	
	if airator then
		local AiratorLabel = vgui.Create("Label", plant_frame)
		AiratorLabel:SetPos( 25, 175 )
		AiratorLabel:SetText( "Automatic airator already built." )
		AiratorLabel:SizeToContents()
	else
		local AiratorButton = vgui.Create( "DButton" )
		AiratorButton:SetParent( plant_frame )
		AiratorButton:SetText( "Build Automatic Airator" )
		AiratorButton:SetPos( 25, 175 )
		AiratorButton:SetSize( 125, 30 )
		AiratorButton.DoClick = function ()
			datastream.StreamToServer( "addairator_stream", { plantEnt } )
			plant_frame:Close()
		end
		
		local AiratorLabel = vgui.Create("Label", plant_frame)
		AiratorLabel:SetPos( 160, 180 )
		AiratorLabel:SetText( "20 Small Parts" )
		AiratorLabel:SizeToContents()
	end
	
	if plantStatus < 100 and canPrune then
		
		local remPercent
		remPercent = 100 - plantStatus
	
		local amountSlider = vgui.Create( "DNumSlider", plant_frame )
	    amountSlider:SetSize( plant_frame:GetWide() - 40, 50 ) -- Keep the second number at 50
	    amountSlider:SetPos( 25, 250 )
	    amountSlider:SetText( "How long to work (%):" )
	    amountSlider:SetMin( 0 )
	    amountSlider:SetMax( 100 )
	    amountSlider:SetValue( remPercent )
	    amountSlider:SetDecimals( 0 )
		
--		local amountLabel = vgui.Create("Label", plant_frame)
--		amountLabel:SetPos( 160, 250 )
--		amountLabel:SetText( "How long to work:" )
--		amountLabel:SizeToContents()
			
--		local amountText = vgui.Create( "DTextEntry", plant_frame )
--		amountText:SetPos( 160,270 )
--		amountText:SetTall( 20 )
--		amountText:SetWide( 75 )
--		amountText:SetEnterAllowed( true )
--		amountText.OnEnter = function()
--			local amount = math.Round(tonumber(amountText:GetValue()))
--			if amount < 1 then return end
--			datastream.StreamToServer( "prune_stream", { plantEnt, amount } )
--			plant_frame:Close()
--		end
	
		local PruneButton = vgui.Create( "DButton" )
		PruneButton:SetParent( plant_frame )
		PruneButton:SetText( "Prune and Water" )
		PruneButton:SetPos( plant_frame:GetWide() / 2 - 125, 300 )
		PruneButton:SetSize( 125, 30 )
		PruneButton.DoClick = function ()
			local amount = math.Round(tonumber(amountSlider:GetValue()))
			if amount < 1 then return end
			datastream.StreamToServer( "prune_stream", { plantEnt, amount } )
			plant_frame:Close()
		end
	end
	
	

	
	-- if fruitLevel > 0 then
		-- local HarvestButton = vgui.Create( "DButton" )
		-- HarvestButton:SetParent( plant_frame )
		-- HarvestButton:SetText( "Harvest Fruits" )
		-- HarvestButton:SetPos( 25, 300 )
		-- HarvestButton:SetSize( 125, 30 )
		-- HarvestButton.DoClick = function ()
			-- datastream.StreamToServer( "harvest_stream", { plantEnt } )
			-- plant_frame:Close()
		-- end
	-- end
end
usermessage.Hook("plant_menu", PlantMenu)
