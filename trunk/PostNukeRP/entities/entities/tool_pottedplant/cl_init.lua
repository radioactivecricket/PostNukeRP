include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end


function PlantMenu( )
	local fruitLevel = math.Round(net:ReadDouble())
	local plantStatus = math.Round(net:ReadDouble())
	local filtered = tobool(net:ReadBit())
	local fertilized = tobool(net:ReadBit())
	local airator = tobool(net:ReadBit())
	local canPrune = tobool(net:ReadBit())
	local plantEnt = net:ReadEntity()
	local ply = LocalPlayer()
	
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
		local FilterButton = vgui.Create( "DButton" )
		FilterButton:SetParent( plant_frame )
		FilterButton:SetText( "Detach Water Purifier" )
		FilterButton:SetPos( 25, 75 )
		FilterButton:SetSize( 125, 30 )
		FilterButton.DoClick = function ()
			--datastream.StreamToServer( "addfilter_stream", { plantEnt } )
			net.Start("addfilter_stream")
				net.WriteEntity(ply)
				net.WriteEntity(plantEnt)
			net.SendToServer()
			plant_frame:Close()
		end
	else
		local FilterButton = vgui.Create( "DButton" )
		FilterButton:SetParent( plant_frame )
		FilterButton:SetText( "Attach Water Purifier" )
		FilterButton:SetPos( 25, 75 )
		FilterButton:SetSize( 125, 30 )
		FilterButton.DoClick = function ()
			--datastream.StreamToServer( "addfilter_stream", { plantEnt } )
			net.Start("addfilter_stream")
				net.WriteEntity(ply)
				net.WriteEntity(plantEnt)
			net.SendToServer()
			plant_frame:Close()
		end
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
			--datastream.StreamToServer( "fertilize_stream", { plantEnt } )
			net.Start("fertilize_stream")
				net.WriteEntity(ply)
				net.WriteEntity(plantEnt)
			net.SendToServer()
			plant_frame:Close()
		end
		
		local FertLabel = vgui.Create("Label", plant_frame)
		FertLabel:SetPos( 160, 130 )
		FertLabel:SetText( "5 Chems" )
		FertLabel:SizeToContents()
	end
	
	if airator then
		local AiratorButton = vgui.Create( "DButton" )
		AiratorButton:SetParent( plant_frame )
		AiratorButton:SetText( "Detach Automatic Airator" )
		AiratorButton:SetPos( 25, 175 )
		AiratorButton:SetSize( 125, 30 )
		AiratorButton.DoClick = function ()
			--datastream.StreamToServer( "addairator_stream", { plantEnt } )
			net.Start("addairator_stream")
				net.WriteEntity(ply)
				net.WriteEntity(plantEnt)
			net.SendToServer()
			plant_frame:Close()
		end
	else
		local AiratorButton = vgui.Create( "DButton" )
		AiratorButton:SetParent( plant_frame )
		AiratorButton:SetText( "Attach Automatic Airator" )
		AiratorButton:SetPos( 25, 175 )
		AiratorButton:SetSize( 125, 30 )
		AiratorButton.DoClick = function ()
			--datastream.StreamToServer( "addairator_stream", { plantEnt } )
			net.Start("addairator_stream")
				net.WriteEntity(ply)
				net.WriteEntity(plantEnt)
			net.SendToServer()
			plant_frame:Close()
		end
	end
	
	if plantStatus < 100 and canPrune then
		local PruneButton = vgui.Create( "DButton" )
		PruneButton:SetParent( plant_frame )
		PruneButton:SetText( "Prune and Water" )
		PruneButton:SetPos( plant_frame:GetWide() / 2 - 125, 300 )
		PruneButton:SetSize( 125, 30 )
		PruneButton.DoClick = function ()
			net.Start("prune_stream")
				net.WriteEntity(ply)
				net.WriteEntity(plantEnt)
			net.SendToServer()
			plant_frame:Close()
		end
	end
end
net.Receive("plant_menu", PlantMenu)
