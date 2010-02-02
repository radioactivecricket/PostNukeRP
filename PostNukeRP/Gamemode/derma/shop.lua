--Build Shop Menu

local shop_frame

function buy_shop()
				 		
	shop_frame = vgui.Create( "DFrame" )
		shop_frame:SetSize( 700, 700 ) --Set the size
		shop_frame:SetPos(ScrW() / 2 - shop_frame:GetWide() / 2, ScrH() / 2 - shop_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
		shop_frame:SetTitle( "Shop Menu" ) --Set title
		shop_frame:SetVisible( true )
		shop_frame:SetDraggable( true )
		shop_frame:ShowCloseButton( true )
		shop_frame:MakePopup()
		
		PNRP.buildMenu(shop_frame)
		
	local PropertySheet = vgui.Create( "DPropertySheet" )
			PropertySheet:SetParent( shop_frame )
			PropertySheet:SetPos( 5, 50 )
			PropertySheet:SetSize( shop_frame:GetWide() - 10 , shop_frame:GetTall() - 60 )
			
			local weaponPanel = PNRP.build_List("weapon", shop_frame, PropertySheet)
			local ammoPanel = PNRP.build_List("ammo", shop_frame, PropertySheet)
			local medicalPanel = PNRP.build_List("medical", shop_frame, PropertySheet)
			local foodPanel = PNRP.build_List("food", shop_frame, PropertySheet)
			local builtitemsPanel = PNRP.build_List("build", shop_frame, PropertySheet)
			local junkPanel = PNRP.build_List("junk", shop_frame, PropertySheet)
			local vehiclePanel = PNRP.build_List("vehicle", shop_frame, PropertySheet)
			local toolsPanel = PNRP.build_List("tool", shop_frame, PropertySheet)
						
			PropertySheet:AddSheet( "Weapons", weaponPanel, "gui/silkicons/bomb", false, false, "Build Weapons" )
			PropertySheet:AddSheet( "Ammo", ammoPanel, "gui/silkicons/box", false, false, "Create Ammo" )
			PropertySheet:AddSheet( "Medical", medicalPanel, "gui/silkicons/heart", false, false, "Medical Items" )
			PropertySheet:AddSheet( "Food and Drink", foodPanel, "gui/silkicons/brick_add", false, false, "Food and Drink Items" )
			PropertySheet:AddSheet( "Build Items", builtitemsPanel, "gui/silkicons/palette", false, false, "Building Materials" )
			PropertySheet:AddSheet( "Build Junk Items", junkPanel, "gui/silkicons/anchor", false, false, "More Building Materials" )
			PropertySheet:AddSheet( "Vehicles", vehiclePanel, "gui/silkicons/car", false, false, "Create Vehicles" )
			PropertySheet:AddSheet( "Tools", toolsPanel, "gui/silkicons/wrench", false, false, "Make Tools - Still in Development" )
			
end

function PNRP.build_List(itemtype, parent_frame, PropertySheet)

	local sc = 0
	local sp = 0
	local ch = 0

	local pnlList = vgui.Create("DPanelList", PropertySheet)
		pnlList:SetPos(20, 80)
		pnlList:SetSize(parent_frame:GetWide() - 40, parent_frame:GetTall() - 100)
		pnlList:EnableVerticalScrollbar(true) 
		pnlList:EnableHorizontal(false) 
		pnlList:SetSpacing(1)
		pnlList:SetPadding(10)
		
		for itemname, item in pairs(PNRP.Items) do
			if item.Type == tostring( itemtype ) then
				
				local pnlPanel = vgui.Create("DPanel")
				pnlPanel:SetTall(75)
				pnlPanel.Paint = function()
				
					draw.RoundedBox( 6, 0, 0, pnlPanel:GetWide(), pnlPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
			
				end
				pnlList:AddItem(pnlPanel)
				
				pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
				pnlPanel.Icon:SetModel(item.Model)
				pnlPanel.Icon:SetPos(3, 5)
				pnlPanel.Icon:SetToolTip( nil )
				pnlPanel.Icon.DoClick = function()
						RunConsoleCommand("pnrp_buildItem", itemname)
						parent_frame:Close()
				end	
				
				pnlPanel.Title = vgui.Create("DLabel", pnlPanel)
				pnlPanel.Title:SetPos(90, 5)
				pnlPanel.Title:SetText(item.Name)
				pnlPanel.Title:SetColor(Color( 0, 0, 0, 255 ))
				pnlPanel.Title:SizeToContents() 
		 		pnlPanel.Title:SetContentAlignment( 5 )
		 		
		 		if item.Scrap != nil then sc = item.Scrap else sc = 0 end
		 		if item.SmallParts != nil then sp = item.SmallParts else sp = 0 end
		 		if item.Chemicals != nil then ch = item.Chemicals else ch = 0 end
		 		
		 		pnlPanel.Cost = vgui.Create("DLabel", pnlPanel)		
				pnlPanel.Cost:SetPos(90, 55)
				pnlPanel.Cost:SetText("Cost: Scrap "..tostring(sc).." | Small Parts "..tostring(sp).." | Chemicals "..tostring(ch))
				pnlPanel.Cost:SetColor(Color( 0, 0, 0, 255 ))
				pnlPanel.Cost:SizeToContents() 
		 		pnlPanel.Cost:SetContentAlignment( 5 )	
		 		
		 		pnlPanel.ClassBuild = vgui.Create("DLabel", pnlPanel)		
				pnlPanel.ClassBuild:SetPos(350, 5)
				pnlPanel.ClassBuild:SetText("Required Class for Creation: "..item.ClassSpawn)
				pnlPanel.ClassBuild:SetColor(Color( 0, 0, 0, 255 ))
				pnlPanel.ClassBuild:SizeToContents() 
		 		pnlPanel.ClassBuild:SetContentAlignment( 5 )
		 		
		 		pnlPanel.ClassBuild = vgui.Create("DLabel", pnlPanel)		
				pnlPanel.ClassBuild:SetPos(90, 40)
				pnlPanel.ClassBuild:SetText(item.Info)
				pnlPanel.ClassBuild:SetColor(Color( 0, 0, 0, 255 ))
				pnlPanel.ClassBuild:SizeToContents() 
		 		pnlPanel.ClassBuild:SetContentAlignment( 5 )	
		 		
		 		pnlPanel.ItemWeight = vgui.Create("DLabel", pnlPanel)		
				pnlPanel.ItemWeight:SetPos(350, 55)
				pnlPanel.ItemWeight:SetText("Weight: "..item.Weight)
				pnlPanel.ItemWeight:SetColor(Color( 0, 0, 0, 255 ))
				pnlPanel.ItemWeight:SizeToContents() 
		 		pnlPanel.ItemWeight:SetContentAlignment( 5 )	
			
			end
		end	
	
	return pnlList

end

concommand.Add( "pnrp_buy_shop", buy_shop )

--EOF