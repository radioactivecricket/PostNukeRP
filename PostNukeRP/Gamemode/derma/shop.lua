--Build Shop Menu

function buy_shop()
	shop_frame = PNRP.PNRP_Frame()
	if not shop_frame then return end
	
	PNRP.RMDerma()
		shop_frame:SetSize( 710, 720 ) --Set the size Extra 40 must be from the top bar
		--Set the window in the middle of the players screen/game window
		shop_frame:SetPos(ScrW() / 2 - shop_frame:GetWide() / 2, ScrH() / 2 - shop_frame:GetTall() / 2) 
		shop_frame:SetTitle( "Shop Menu" ) --Set title
		shop_frame:SetVisible( true )
		shop_frame:SetDraggable( true )
		shop_frame:ShowCloseButton( true )
		shop_frame:MakePopup()
		shop_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		PNRP.AddMenu(menu)
		
		local screenBG = vgui.Create("DImage", shop_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_1b.png" )
			screenBG:SetSize(shop_frame:GetWide(), shop_frame:GetTall())
		PNRP.buildMenu(shop_frame)
		
	local PropertySheet = vgui.Create( "DPropertySheet" )
			PropertySheet:SetParent( shop_frame )
			PropertySheet:SetPos( 40, 60 )
			PropertySheet:SetSize( shop_frame:GetWide() - 85 , shop_frame:GetTall() - 105 )
			PropertySheet:SetFadeTime( 0.5 )
			PropertySheet.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end

			
			local weaponPanel = PNRP.build_List("weapon", shop_frame, PropertySheet)
			local ammoPanel = PNRP.build_List("ammo", shop_frame, PropertySheet)
			local medicalPanel = PNRP.build_List("medical", shop_frame, PropertySheet)
			local foodPanel = PNRP.build_List("food", shop_frame, PropertySheet)
--			local builtitemsPanel = PNRP.build_List("build", shop_frame, PropertySheet)
			local junkPanel = PNRP.build_List("junk", shop_frame, PropertySheet)
			local vehiclePanel = PNRP.build_List("vehicle", shop_frame, PropertySheet)
			local toolsPanel = PNRP.build_List("tool", shop_frame, PropertySheet)
			local partsPanel = PNRP.build_List("part", shop_frame, PropertySheet)
			local miscPanel = PNRP.build_List("misc", shop_frame, PropertySheet)
						
			PropertySheet:AddSheet( "Weapons", weaponPanel, "gui/icons/bomb.png", false, false, "Build Weapons" )
			PropertySheet:AddSheet( "Ammo", ammoPanel, "gui/icons/box.png", false, false, "Create Ammo" )
			PropertySheet:AddSheet( "Medical", medicalPanel, "gui/icons/heart.png", false, false, "Medical Items" )
			PropertySheet:AddSheet( "Food and Drink", foodPanel, "gui/icons/cup_add.png", false, false, "Food and Drink Items" )
--			PropertySheet:AddSheet( "Build Items", builtitemsPanel, "gui/icons/palette", false, false, "Building Materials" )
			PropertySheet:AddSheet( "Junk", junkPanel, "gui/icons/anchor.png", false, false, "More Building Materials" )
			PropertySheet:AddSheet( "Vehicles", vehiclePanel, "gui/icons/car.png", false, false, "Create Vehicles" )
			PropertySheet:AddSheet( "Tools", toolsPanel, "gui/icons/wrench.png", false, false, "Make Tools - Still in Development" )
			PropertySheet:AddSheet( "Parts", partsPanel, "gui/icons/cog.png", false, false, "Got to find them all." )
			PropertySheet:AddSheet( "Misc", miscPanel, "gui/icons/bug.png", false, false, "Pets, paper, etc..." )

end

function PNRP.build_List(itemtype, parent_frame, PropertySheet)

	local ply = LocalPlayer()
	local sc = 0
	local sp = 0
	local ch = 0
	
	local textColor = Color(200,200,200,255)
	local dListBKColor = Color(50,50,50,255)
	
	if itemtype == "vehicle" and not (ply:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1)then
		local vehicleInfoPanel = vgui.Create( "DPanel", parent_frame )
			vehicleInfoPanel:SetPos( 5, 5 )
			vehicleInfoPanel:SetSize( parent_frame:GetWide() - 60, parent_frame:GetTall() - 120 )
			vehicleInfoPanel.Paint = function() end
			
			--local iconImg = "entities/Jalopy.png"
			local img = vgui.Create( "DImage", vehicleInfoPanel )
			img:SetSize( 125, 125 )
			img:SetPos( 5, 5 )
			img:SetImage( "entities/Jalopy.png" )
			
			local titleTxt = vgui.Create("DLabel", vehicleInfoPanel)
			titleTxt:SetPos(150, 5)
			titleTxt:SetText("PostNukeRP Vehicle Building System")
			titleTxt:SetFont("Trebuchet18")
			titleTxt:SizeToContents() 
			titleTxt:SetColor(Color( 0, 255, 0, 255 ))
			titleTxt:SetContentAlignment( 5 )
			local addonTxt = vgui.Create("DLabel", vehicleInfoPanel)
			addonTxt:SetPos(150, 20)
			addonTxt:SetText("Currently using Doc's Half-Life 2 Driveable Vehicles")
			addonTxt:SizeToContents() 
			addonTxt:SetColor(Color( 0, 255, 0, 255 ))
			addonTxt:SetContentAlignment( 5 )
			
			local instStr = "In the wasteland you will find Old Car Bodies. These will be needed to gather parts from.\n"
			instStr = instStr.."Only Scavengers and Engineers can recover parts from these hulls, but everyone can get resources.\n"
			instStr = instStr.."You will need a Toolbox in order to use the hull. \n"
			instStr = instStr.."\n"
			instStr = instStr.."Engineers will be able to recover the hull to make the vehicle from them.\n"
			instStr = instStr.."A hull has to be 50% or greater to recover a hull, and has to be 25% or greater to recover a part.\n"
			instStr = instStr.."\n"
			instStr = instStr.."Every hull is unique and you will need the right one for the vehicle you want."
			local instTxt = vgui.Create("DLabel", vehicleInfoPanel)
				instTxt:SetPos(20, 150)
				instTxt:SetText(instStr)
				instTxt:SetFont("Trebuchet18")
				instTxt:SizeToContents() 
				instTxt:SetColor(Color( 0, 255, 0, 255 ))
				instTxt:SetContentAlignment( 5 )
			
			local ToolScrollPanel = vgui.Create( "DPanel", vehicleInfoPanel )
				ToolScrollPanel:SetPos( 20, 325 )
				ToolScrollPanel:SetSize( parent_frame:GetWide() - 60, 150 )
				ToolScrollPanel.Paint = function() end
				local partsTxt = vgui.Create("DLabel", ToolScrollPanel)
				partsTxt:SetPos(0, 0)
				partsTxt:SetText("Parts that can be recovered:")
				partsTxt:SetFont("Trebuchet18")
				partsTxt:SizeToContents() 
				partsTxt:SetColor(Color( 0, 255, 0, 255 ))
				partsTxt:SetContentAlignment( 5 )
				
				local ToolScroller = vgui.Create("DHorizontalScroller", ToolScrollPanel) --Create the scroller
				ToolScroller:SetSize(ToolScrollPanel:GetWide(), ToolScrollPanel:GetTall())
				ToolScroller:AlignTop(20)
				ToolScroller:AlignLeft(0)
				ToolScroller:SetOverlap(-1)
				
				for k, v in pairs(PNRP.CarParts) do
					local toolItem = PNRP.Items[k]
					local pnlTPanel = vgui.Create("DPanel", ToolScroller)
					pnlTPanel:SetSize( 50,50 )
					pnlTPanel.Paint = function() end
					
					local toolIcon = vgui.Create( "SpawnIcon", pnlTPanel )
						toolIcon:SetSize( pnlTPanel:GetWide(), pnlTPanel:GetTall() )
						toolIcon:SetModel( toolItem.Model )
						toolIcon:SetToolTip( toolItem.Name )
						toolIcon.DoClick = function() end
					ToolScroller:AddPanel(pnlTPanel)
				end
			
			local repLblTxt = vgui.Create("DLabel", vehicleInfoPanel)
				repLblTxt:SetPos(20, 420)
				repLblTxt:SetText("Vehicle Repair")
				repLblTxt:SetFont("Trebuchet18")
				repLblTxt:SizeToContents() 
				repLblTxt:SetColor(Color( 0, 255, 0, 255 ))
				repLblTxt:SetContentAlignment( 5 )
				
			local repStr = "Only Engineers with a toolbox can repair vehicles.\n"
			repStr = repStr.."Cost of repair is 1 Scrap per second while repairing, and can be stopped by pressing E on the vehicle.\n"
			repStr = repStr.."Repair rate is affected by your Construction Skill.\n\n"
			repStr = repStr.."Vehicles with a HP below 50 will consume more gas. The lower the HP the more it will consume."
			local repTxt = vgui.Create("DLabel", vehicleInfoPanel)
				repTxt:SetPos(20, 435)
				repTxt:SetText(repStr)
				repTxt:SizeToContents() 
				repTxt:SetColor(Color( 0, 255, 0, 255 ))
				repTxt:SetContentAlignment( 5 )
		
		return vehicleInfoPanel
	end
	
	local pnlList = vgui.Create("DPanelList", PropertySheet)
		pnlList:SetPos(20, 80)
		pnlList:SetSize(parent_frame:GetWide() - 60, parent_frame:GetTall() - 120)
		pnlList:EnableVerticalScrollbar(true) 
		pnlList:EnableHorizontal(false) 
		pnlList:SetSpacing(1)
		pnlList:SetPadding(10)
		
		for itemname, item in pairs(PNRP.Items) do
			if item.ShopHide == true and not (ply:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1)then
				--Do nothing
			else
				if item.Type == tostring( itemtype ) then
					
					local pnlPanel = vgui.Create("DPanel")
					pnlPanel:SetTall(75)
					pnlPanel.Paint = function()
					--	draw.RoundedBox( 6, 0, 0, pnlPanel:GetWide(), pnlPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
						draw.RoundedBox( 1, 0, 0, pnlPanel:GetWide(), 1, Color( 0, 255, 0, 80 ) )
						draw.RoundedBox( 1, 0, pnlPanel:GetTall()-1, pnlPanel:GetWide(), 1, Color( 0, 255, 0, 80 ) )
					end
					pnlList:AddItem(pnlPanel)
										
					if ply:Team() == TEAM_ENGINEER then
						if item.Scrap != nil then sc = math.ceil( item.Scrap * (1 - (0.02 * ply:GetSkill("Construction"))))  else sc = 0 end
						if item.SmallParts != nil then sp = math.ceil(item.SmallParts * (1 - (0.02 * ply:GetSkill("Construction")))) else sp = 0 end
						if item.Chemicals != nil then ch = math.ceil(item.Chemicals * (1 - (0.02 * ply:GetSkill("Construction")))) else ch = 0 end
					else
						if item.Scrap != nil then sc = item.Scrap else sc = 0 end
						if item.SmallParts != nil then sp = item.SmallParts else sp = 0 end
						if item.Chemicals != nil then ch = item.Chemicals else ch = 0 end
					end
					
					local neededParts = item.ToolCheck( )
					local partsText = nil
					if type(neededParts) == "table" then
						partsText = "Needed Parts: \n--------------------"
						for p, n in pairs(neededParts) do
							if PNRP.Items[p] then
								partsText = partsText.."\n"..PNRP.Items[p].Name.." : "..tostring(n)
							end
						end
					end
					
					if ply:Team() == TEAM_ENGINEER then
						if partsText == nil then 
							partsText = ""
						else
							partsText = partsText.."\n \n"
						end
						partsText = partsText.."Skill Discount: \n-------------------- \n"
						partsText = partsText.."Scrap: "..tostring(sc).." | "..item.Scrap.."\n"
						partsText = partsText.."Small Parts: "..tostring(sp).." | "..item.SmallParts.."\n"
						partsText = partsText.."Chemicals: "..tostring(ch).." | "..item.Chemicals.."\n"
					end
					
					pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
					pnlPanel.Icon:SetModel(item.Model)
					pnlPanel.Icon:SetPos(3, 5)
					pnlPanel.Icon:SetToolTip( partsText )
					pnlPanel.Icon.DoClick = function()
							RunConsoleCommand("pnrp_buildItem", itemname)
							parent_frame:Close()
					end	
					
					pnlPanel.Title = vgui.Create("DLabel", pnlPanel)
					pnlPanel.Title:SetPos(90, 5)
					pnlPanel.Title:SetText(item.Name)
					pnlPanel.Title:SetColor(Color( 0, 255, 0, 255 ))
					pnlPanel.Title:SizeToContents() 
					pnlPanel.Title:SetContentAlignment( 5 )
															
					pnlPanel.Cost = vgui.Create("DLabel", pnlPanel)		
					pnlPanel.Cost:SetPos(90, 55)
					pnlPanel.Cost:SetText("Cost: Scrap "..tostring(sc).." | Small Parts "..tostring(sp).." | Chemicals "..tostring(ch))
					pnlPanel.Cost:SetColor(Color( 0, 255, 0, 255 ))
					pnlPanel.Cost:SizeToContents() 
					pnlPanel.Cost:SetContentAlignment( 5 )	
					
					pnlPanel.ClassBuild = vgui.Create("DLabel", pnlPanel)		
					pnlPanel.ClassBuild:SetPos(340, 5)
					pnlPanel.ClassBuild:SetText("Required Class for Creation: "..item.ClassSpawn)
					pnlPanel.ClassBuild:SetColor(Color( 0, 200, 0, 255 ))
					pnlPanel.ClassBuild:SizeToContents() 
					pnlPanel.ClassBuild:SetContentAlignment( 5 )
					
					pnlPanel.ItmInfo = vgui.Create("DLabel", pnlPanel)		
					pnlPanel.ItmInfo:SetPos(90, 25)
					pnlPanel.ItmInfo:SetText(item.Info)
					pnlPanel.ItmInfo:SetColor(Color( 0, 200, 0, 255 ))
					pnlPanel.ItmInfo:SetWide(300)
					pnlPanel.ItmInfo:SetTall(25)
					pnlPanel.ItmInfo:SetWrap(true)
					pnlPanel.ItmInfo:SetContentAlignment( 5 )	
					
					local weightTXT = "Weight: "..item.Weight
					if item.Capacity then
						weightTXT = weightTXT.." | Capacity: "..item.Capacity
					end
					if item.HP then
						weightTXT = weightTXT.." | HP: "..item.HP
					end
					pnlPanel.ItemWeight = vgui.Create("DLabel", pnlPanel)		
					pnlPanel.ItemWeight:SetPos(340, 55)
					pnlPanel.ItemWeight:SetText(weightTXT)
					pnlPanel.ItemWeight:SetColor(Color( 0, 255, 0, 255 ))
					pnlPanel.ItemWeight:SizeToContents() 
					pnlPanel.ItemWeight:SetContentAlignment( 5 )	
					
					if item.Type == "vehicle" or item.Type == "tool" or item.Type == "junk" or item.Type == "misc" then
						--Since GMod does not like Not or's	
					else
						pnlPanel.bulkSlider = vgui.Create( "DNumSlider", pnlPanel )
						pnlPanel.bulkSlider:SetPos(300, 45)
						pnlPanel.bulkSlider:SetWide( 280 )
						pnlPanel.bulkSlider:SetText( "" )
						pnlPanel.bulkSlider:SetMin( 1 )
						pnlPanel.bulkSlider:SetMax( 100 )
						pnlPanel.bulkSlider:SetDecimals( 0 )
						pnlPanel.bulkSlider:SetValue( 1 )
						pnlPanel.bulkSlider.Label:SetColor(textColor)
						pnlPanel.bulkSlider:SetBGColor(textColor)
						
						pnlPanel.BulkBtn = vgui.Create("DButton", pnlPanel )
						pnlPanel.BulkBtn:SetPos(485, 30)
						pnlPanel.BulkBtn:SetSize(80,17)
						pnlPanel.BulkBtn:SetText( "Create Bulk" )
						pnlPanel.BulkBtn.DoClick = function() 
							net.Start("SpawnBulkCrate")
								net.WriteEntity(ply)
								net.WriteString(itemname)
								net.WriteDouble(math.Round(tonumber(pnlPanel.bulkSlider:GetValue())))
							net.SendToServer()
							parent_frame:Close()
						end
					end
				end
			end
		end	
	
	return pnlList

end

concommand.Add( "pnrp_buy_shop", buy_shop )

--EOF