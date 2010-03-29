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
	
	local FLevelLabel = vgui.Create("Label", plant_frame)
	FLevelLabel:SetPos(10,25)
	FLevelLabel:SetText("Fruits on tree:  "..tostring(fruitLevel))
	FLevelLabel:SizeToContents()
	
	local StatusLabel = vgui.Create("Label", plant_frame)
	StatusLabel:SetPos(10,50)
	StatusLabel:SetText("Plant Status:  "..tostring(plantStatus).."%")
	StatusLabel:SizeToContents()
	
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
		FilterLabel:SetPos( 160, 75 )
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
		FertLabel:SetPos( 160, 125 )
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
		AiratorLabel:SetPos( 160, 175 )
		AiratorLabel:SetText( "20 Small Parts" )
		AiratorLabel:SizeToContents()
	end
	
	if plantStatus < 100 and canPrune then
		local PruneButton = vgui.Create( "DButton" )
		PruneButton:SetParent( plant_frame )
		PruneButton:SetText( "Prune and Water" )
		PruneButton:SetPos( 25, 250 )
		PruneButton:SetSize( 125, 30 )
		PruneButton.DoClick = function ()
			datastream.StreamToServer( "prune_stream", { plantEnt } )
			plant_frame:Close()
		end
	end
	
	if fruitLevel > 0 then
		local HarvestButton = vgui.Create( "DButton" )
		HarvestButton:SetParent( plant_frame )
		HarvestButton:SetText( "Harvest Fruits" )
		HarvestButton:SetPos( 25, 300 )
		HarvestButton:SetSize( 125, 30 )
		HarvestButton.DoClick = function ()
			datastream.StreamToServer( "harvest_stream", { plantEnt } )
			plant_frame:Close()
		end
	end
end
usermessage.Hook("plant_menu", PlantMenu)
