
function GM.car_inventory_window( )
	
	inventory_frame = PNRP.PNRP_Frame()
	if not inventory_frame then return end

	PNRP.RMDerma()
	
	local MyCarInventory = net.ReadTable()
	local PlayerInvWeight = net.ReadString()
	local CurCarInvWeight = net.ReadString()
	
	local ply = LocalPlayer()			 		
		inventory_frame:SetSize( 710, 720 ) --Set the size
		inventory_frame:SetPos(ScrW() / 2 - inventory_frame:GetWide() / 2, ScrH() / 2 - inventory_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
		inventory_frame:SetTitle( "Car Inventory Menu" ) --Set title
		inventory_frame:SetVisible( true )
		inventory_frame:SetDraggable( true )
		inventory_frame:ShowCloseButton( true )
		inventory_frame:MakePopup()
		inventory_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		PNRP.AddMenu(inventory_frame)
		
		local screenBG = vgui.Create("DImage", inventory_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_1b.png" )
			screenBG:SetKeepAspect()
			screenBG:SizeToContents()
			screenBG:SetSize(inventory_frame:GetWide(), inventory_frame:GetTall())
		
		PNRP.buildMenu(inventory_frame)
		
	local PropertySheet = vgui.Create( "DPropertySheet" )
			PropertySheet:SetParent( inventory_frame )
			PropertySheet:SetPos( 40, 60 )
			PropertySheet:SetSize( inventory_frame:GetWide() - 85 , inventory_frame:GetTall() - 105 )
			PropertySheet:SetFadeTime( 0.5 )
			PropertySheet.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
			
			local weaponPanel = PNRP.build_car_inv_List(ply, "weapon", inventory_frame, PropertySheet, MyCarInventory)
			local ammoPanel = PNRP.build_car_inv_List(ply, "ammo", inventory_frame, PropertySheet, MyCarInventory)
			local medicalPanel = PNRP.build_car_inv_List(ply, "medical", inventory_frame, PropertySheet, MyCarInventory)
			local foodPanel = PNRP.build_car_inv_List(ply, "food", inventory_frame, PropertySheet, MyCarInventory)
			local toolsPanel = PNRP.build_car_inv_List(ply, "tool", inventory_frame, PropertySheet, MyCarInventory)
			local partsPanel = PNRP.build_car_inv_List(ply, "part", inventory_frame, PropertySheet, MyCarInventory)
			local miscPanel = PNRP.build_car_inv_List(ply, "misc", inventory_frame, PropertySheet, MyCarInventory)
			local allPanel = PNRP.build_car_inv_List(ply, "all", inventory_frame, PropertySheet, MyCarInventory)
						
			PropertySheet:AddSheet( "Weapons", weaponPanel, "gui/icons/bomb.png", false, false, "Build Weapons" )
			PropertySheet:AddSheet( "Ammo", ammoPanel, "gui/icons/box.png", false, false, "Create Ammo" )
			PropertySheet:AddSheet( "Medical", medicalPanel, "gui/icons/heart.png", false, false, "Medical Items" )
			PropertySheet:AddSheet( "Food and Drink", foodPanel, "gui/icons/cup_add.png", false, false, "Food and Drink Items" )
			PropertySheet:AddSheet( "Tools", toolsPanel, "gui/icons/wrench.png", false, false, "Make Tools - Still in Development" )
			PropertySheet:AddSheet( "Parts", partsPanel, "gui/icons/cog.png", false, false, "Got to find them all." )
			PropertySheet:AddSheet( "Misc", miscPanel, "gui/icons/bug.png", false, false, "Birds, paper, etc..." )
			PropertySheet:AddSheet( "All", allPanel, "gui/icons/add.png", false, false, "Everything including the kitchen sink." )
			
	local InvWeight = vgui.Create("DLabel", inventory_frame)		
			InvWeight:SetPos(550, 33 )
			local maxCarWeight	
			maxCarWeight = tostring(CurCarMaxWeight)
			local whColor
			if tonumber(CurCarInvWeight) >= tonumber(maxCarWeight) then
				whColor = Color( 255, 0, 0, 255 )
			else
				whColor = Color( 0, 255, 0, 255 )
			end
			local invWeightText = "Car Weight: "..tostring(CurCarInvWeight).."/"..tostring(maxCarWeight).."\n"
			local maxWeight
			if ply:Team() == TEAM_SCAVENGER then
				maxWeight = GetConVar("pnrp_packCapScav"):GetInt() + (GetSkill("Backpacking")*10)
			else
				maxWeight = GetConVar("pnrp_packCap"):GetInt() + (GetSkill("Backpacking")*10)
			end
			invWeightText = invWeightText.."Your Weight: "..tostring(PlayerInvWeight).."/"..tostring(maxWeight)
			InvWeight:SetText(invWeightText)
			InvWeight:SetColor(whColor)
			InvWeight:SizeToContents() 

end

function PNRP.build_car_inv_List(ply, itemtype, parent_frame, PropertySheet, MyCarInventory)

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
			if item.Type == tostring( itemtype ) or tostring( itemtype ) == "all" then
				for k, v in pairs( MyCarInventory ) do
					if v["count"] > 0 then
						if string.lower(v["itemid"]) == string.lower(itemname) then
							local pnlPanel = vgui.Create("DPanel")
							pnlPanel:SetTall(75)
							pnlPanel.Paint = function()
							--	draw.RoundedBox( 6, 0, 0, pnlPanel:GetWide(), pnlPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
								draw.RoundedBox( 1, 0, 0, pnlPanel:GetWide(), 1, Color( 0, 255, 0, 80 ) )
								draw.RoundedBox( 1, 0, pnlPanel:GetTall()-1, pnlPanel:GetWide(), 1, Color( 0, 255, 0, 80 ) )
							end
							pnlList:AddItem(pnlPanel)
							
							local model = item.Model
							local skin = 0
							if v["status_table"] != "" then
								local newModel = PNRP.GetFromStat(v["status_table"], "Model")
								local newSkin = PNRP.GetFromStat(v["status_table"], "Skin")
								if newModel then model = newModel end
								if newSkin then skin = tonumber(newSkin) end
							end
							pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
							pnlPanel.Icon:SetModel(model, skin)
							pnlPanel.Icon:SetPos(3, 5)
							pnlPanel.Icon:SetToolTip( nil )
							pnlPanel.Icon.DoClick = function()
								if v["iid"] == "" then
									if item.SaveState then
										net.Start("pnrp_DropPersistItem")
											net.WriteEntity(ply)
											net.WriteString(v["itemid"])
											net.WriteString(v["iid"])
											net.WriteString("carInv")
										net.SendToServer()
									else
										RunConsoleCommand("carinventory_drop", itemname)
									end
									parent_frame:Close()
								else
									net.Start("pnrp_DropPersistItem")
										net.WriteEntity(ply)
										net.WriteString(v["itemid"])
										net.WriteString(v["iid"])
									net.SendToServer()
									
									parent_frame:Close()
								end
							end	
							
							pnlPanel.Title = vgui.Create("DLabel", pnlPanel)
							pnlPanel.Title:SetPos(90, 5)
							pnlPanel.Title:SetText(item.Name)
							pnlPanel.Title:SetColor(Color( 0, 255, 0, 255 ))
							pnlPanel.Title:SizeToContents() 
							pnlPanel.Title:SetContentAlignment( 5 )
							
							if item.Scrap != nil then sc = item.Scrap else sc = 0 end
							if item.SmallParts != nil then sp = item.SmallParts else sp = 0 end
							if item.Chemicals != nil then ch = item.Chemicals else ch = 0 end
							
							local countTxt = "Count: "..tostring(v["count"])
							if v["status_table"] != "" then
								countTxt = ""
								local HP = PNRP.GetFromStat(v["status_table"], "HP")
								if HP then 	countTxt = "HP: "..HP end
								local PowerLevel = PNRP.GetFromStat(v["status_table"], "PowerLevel")
								if PowerLevel then 	countTxt = countTxt.." Charge: "..tostring(math.Round(PowerLevel/100)).."% " end
								local FuelLevel = PNRP.GetFromStat(v["status_table"], "FuelLevel")
								if FuelLevel then countTxt = countTxt.." Fuel: "..tostring(FuelLevel) end
							end
							pnlPanel.Count = vgui.Create("DLabel", pnlPanel)		
							pnlPanel.Count:SetPos(90, 55)
							pnlPanel.Count:SetText(countTxt)
							pnlPanel.Count:SetColor(Color( 0, 255, 0, 255 ))
							pnlPanel.Count:SizeToContents() 
							pnlPanel.Count:SetContentAlignment( 5 )	
							
							pnlPanel.ClassBuild = vgui.Create("DLabel", pnlPanel)		
							pnlPanel.ClassBuild:SetPos(250, 5)
							pnlPanel.ClassBuild:SetText("Required Class: "..item.ClassSpawn)
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
							pnlPanel.ItemWeight = vgui.Create("DLabel", pnlPanel)		
							pnlPanel.ItemWeight:SetPos(340, 55)
							pnlPanel.ItemWeight:SetText(weightTXT)
							pnlPanel.ItemWeight:SetColor(Color( 0, 200, 0, 255 ))
							pnlPanel.ItemWeight:SizeToContents() 
							pnlPanel.ItemWeight:SetContentAlignment( 5 )
							
							pnlPanel.sendToInv = vgui.Create("DButton", pnlPanel )
							pnlPanel.sendToInv:SetPos(230, 55)
							pnlPanel.sendToInv:SetSize(100,17)
							pnlPanel.sendToInv:SetText( "Send to To Inv" ) 
							pnlPanel.sendToInv.DoClick = function()
								if v["iid"] == "" then
									if item.SaveState then
										net.Start("pnrp_AddToInvFromCarPersist")
											net.WriteEntity(ply)
											net.WriteString(v["itemid"])
											net.WriteString(v["iid"])
											net.WriteString("carInv")
										net.SendToServer()
									else
										net.Start("pnrp_addtoinvfromcar")
											net.WriteEntity(ply)
											net.WriteString(itemname)
										net.SendToServer()
									end
								else
									net.Start("pnrp_AddToInvFromCarPersist")
										net.WriteEntity(ply)
										net.WriteString(v["itemid"])
										net.WriteString(v["iid"])
									net.SendToServer()
								end
								
								parent_frame:Close()
							end	
							
							if v["iid"] == "" then
								pnlPanel.bulkSlider = vgui.Create( "DNumSlider", pnlPanel )
								pnlPanel.bulkSlider:SetPos(400, 20) 
								pnlPanel.bulkSlider:SetWide( 175 )
								pnlPanel.bulkSlider:SetText( "" )
								pnlPanel.bulkSlider:SetDecimals( 0 )
								pnlPanel.bulkSlider:SetMin( 1 )
								pnlPanel.bulkSlider:SetMax( v["count"] )
								pnlPanel.bulkSlider:SetValue( 1 )
								pnlPanel.bulkSlider.Label:SizeToContents()
							end
							
							if item.Type == "tool" or item.Type == "junk" or v["iid"] ~= "" then
								--Since GMod does not like Not or's
							else
								pnlPanel.BulkBtn = vgui.Create("DButton", pnlPanel )
								pnlPanel.BulkBtn:SetPos(485, 5)
								pnlPanel.BulkBtn:SetSize(80,17)
								pnlPanel.BulkBtn:SetText( "Drop Bulk" )
								pnlPanel.BulkBtn.DoClick = function() 
									net.Start("DropBulkCrateCar")
										net.WriteEntity(ply)
										net.WriteString(itemname)
										net.WriteDouble(math.Round(tonumber(pnlPanel.bulkSlider:GetValue())))
									net.SendToServer()
									parent_frame:Close()
								end
							end
							
							pnlPanel.salvageItem = vgui.Create("DButton", pnlPanel )
							pnlPanel.salvageItem:SetPos(485, 55)
							pnlPanel.salvageItem:SetSize(80,17)
							pnlPanel.salvageItem:SetText( "Salvage Item" )
							pnlPanel.salvageItem.DoClick = function() 
								if v["iid"] == "" then
									local getBSalvageCount = pnlPanel.bulkSlider:GetValue()
									if getBSalvageCount then
										if getBSalvageCount < 0 then
											getBSalvageCount = 0
										end
										if getBSalvageCount > v["count"] then
											getBSalvageCount = v["count"]
										end
										local sndSTR = item.ID..","..tostring(math.Round(getBSalvageCount))
										PNRP.OptionVerify( "pnrp_docarsalvage", sndSTR, nil, nil) 
										parent_frame:Close() 
									end
								else
									PNRP.OptionVerify( "pnrp_dopersalvage", tostring(v["iid"]), nil, nil) parent_frame:Close()
								end
							end
						end
						
					end
				end
			end
		end	
	
	return pnlList

end
net.Receive( "pnrp_OpenCarInvWindow", GM.car_inventory_window )

function GM.initCarInventory(ply)

	local foundCar = false
	for _, car in pairs(ents.FindInSphere( ply:GetPos(), 200 )) do
		local ItemID = PNRP.FindItemID( car:GetClass() )
		if ItemID != nil then
			if ItemID == "vehicle_jalopy" and car:GetModel() == "models/buggy.mdl" then
				ItemID = "vehicle_jeep"
			end
			local myType = PNRP.Items[ItemID].Type
			if tostring(car:GetNetVar( "Owner_UID" , "None" )) == PNRP:GetUID(ply) && myType == "vehicle" then
				foundCar = true
			end
		end
	end
	
	if foundCar then
		if CurCarMaxWeight != nil then
			net.Start("pnrp_OpenCarInventory")
				net.WriteEntity(ply)
			net.SendToServer()
		else
			ply:ChatPrint("You need to use F3 on your car.")
		end
	else
		ply:ChatPrint("You are not near your car.")
	end

end
concommand.Add( "pnrp_carinv",  GM.initCarInventory )

--EOF