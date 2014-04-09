--Build Car Inventory Window

local inventory_frame
local carFrameCK = false

function GM.car_inventory_window( )
	--Stops the multi window exploit
	if carFrameCK then return end 
	carFrameCK = true
	PNRP.RMDerma()
	
	local MyCarInventory = net.ReadTable()
	local PlayerInvWeight = net.ReadString()
	local CurCarInvWeight = net.ReadString()
	
	local ply = LocalPlayer()			 		
	inventory_frame = vgui.Create( "DFrame" )
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
			
	function inventory_frame:Close()                  
		carFrameCK = false                  
		self:SetVisible( false )                  
		self:Remove()          
	end 

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
		pnlList.Paint = function()
		--	draw.RoundedBox( 8, 0, 0, pnlList:GetWide(), pnlList:GetTall(), Color( 50, 50, 50, 255 ) )
		end		
		
		for itemname, item in pairs(PNRP.Items) do
			if item.Type == tostring( itemtype ) or tostring( itemtype ) == "all" then
				for k, v in pairs( MyCarInventory ) do
					if v > 0 then
						if k == itemname then
							local pnlPanel = vgui.Create("DPanel")
							pnlPanel:SetTall(75)
							pnlPanel.Paint = function()
							
								draw.RoundedBox( 6, 0, 0, pnlPanel:GetWide(), pnlPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
						
							end
							pnlList:AddItem(pnlPanel)
							
							pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
							pnlPanel.Icon:SetModel(item.Model)
							pnlPanel.Icon:SetPos(3, 5)
							pnlPanel.Icon:SetToolTip( nil )
							pnlPanel.Icon.DoClick = function()
									RunConsoleCommand("carinventory_drop", itemname)
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
							
							pnlPanel.Count = vgui.Create("DLabel", pnlPanel)		
							pnlPanel.Count:SetPos(90, 55)
							pnlPanel.Count:SetText("Count: "..tostring(v))
							pnlPanel.Count:SetColor(Color( 0, 0, 0, 255 ))
							pnlPanel.Count:SizeToContents() 
							pnlPanel.Count:SetContentAlignment( 5 )	
							
							pnlPanel.ClassBuild = vgui.Create("DLabel", pnlPanel)		
							pnlPanel.ClassBuild:SetPos(250, 5)
							pnlPanel.ClassBuild:SetText("Required Class: "..item.ClassSpawn)
							pnlPanel.ClassBuild:SetColor(Color( 0, 0, 0, 255 ))
							pnlPanel.ClassBuild:SizeToContents() 
							pnlPanel.ClassBuild:SetContentAlignment( 5 )
							
							pnlPanel.ClassBuild = vgui.Create("DLabel", pnlPanel)		
							pnlPanel.ClassBuild:SetPos(90, 25)
							pnlPanel.ClassBuild:SetText(item.Info)
							pnlPanel.ClassBuild:SetColor(Color( 0, 0, 0, 255 ))
							pnlPanel.ClassBuild:SetWide(300)
							pnlPanel.ClassBuild:SetTall(25)
							pnlPanel.ClassBuild:SetWrap(true) 
							pnlPanel.ClassBuild:SetContentAlignment( 5 )	
							
							pnlPanel.ItemWeight = vgui.Create("DLabel", pnlPanel)		
							pnlPanel.ItemWeight:SetPos(340, 55)
							pnlPanel.ItemWeight:SetText("Weight: "..item.Weight)
							pnlPanel.ItemWeight:SetColor(Color( 0, 0, 0, 255 ))
							pnlPanel.ItemWeight:SizeToContents() 
							pnlPanel.ItemWeight:SetContentAlignment( 5 )
							
							pnlPanel.sendToInv = vgui.Create("DButton", pnlPanel )
							pnlPanel.sendToInv:SetPos(400, 55)
							pnlPanel.sendToInv:SetSize(80,18)
							pnlPanel.sendToInv:SetText( "Send to To Inv" )
	--				    	pnlPanel.sendToInv:SizeToContents() 
							pnlPanel.sendToInv.DoClick = function()
							
							--	RunConsoleCommand("pnrp_addtoinvfromcar",item.ID)
								net.Start("pnrp_addtoinvfromcar")
									net.WriteEntity(ply)
									net.WriteString(itemname)
								net.SendToServer()
								parent_frame:Close()
								
							end	
								
							pnlPanel.bulkSlider = vgui.Create( "DNumSlider", pnlPanel )
							pnlPanel.bulkSlider:SetPos(400, 20) 
							pnlPanel.bulkSlider:SetWide( 175 )
							pnlPanel.bulkSlider:SetText( "" )
							pnlPanel.bulkSlider:SetDecimals( 0 )
							pnlPanel.bulkSlider:SetMin( 1 )
							pnlPanel.bulkSlider:SetMax( v )
							pnlPanel.bulkSlider:SetValue( 1 )
							pnlPanel.bulkSlider.Label:SizeToContents()
							
							if item.Type == "tool" or item.Type == "junk" then
								--Since GMod does not like Not or's
							else
								pnlPanel.BulkBtn = vgui.Create("DButton", pnlPanel )
								pnlPanel.BulkBtn:SetPos(485, 5)
								pnlPanel.BulkBtn:SetSize(80,17)
								pnlPanel.BulkBtn:SetText( "Drop Bulk" )
								pnlPanel.BulkBtn.DoClick = function() 
									--datastream.StreamToServer( "DropBulkCrateCar", {itemname, pnlPanel.bulkSlider:GetValue() } )
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
								local getBSalvageCount = pnlPanel.bulkSlider:GetValue()
								if getBSalvageCount then
									if getBSalvageCount < 0 then
										getBSalvageCount = 0
									end
									if getBSalvageCount > v then
										getBSalvageCount = v
									end
									local sndSTR = item.ID..","..tostring(math.Round(getBSalvageCount))
									PNRP.OptionVerify( "pnrp_docarsalvage", sndSTR, nil, nil) 
									parent_frame:Close() 
								end
							end
						end
						
					end
				end
			end
		end	
	
	return pnlList

end
--datastream.Hook( "pnrp_OpenCarInvWindow", GM.car_inventory_window )
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
			if tostring(car:GetNetworkedString( "Owner_UID" , "None" )) == PNRP:GetUID(ply) && myType == "vehicle" then
				foundCar = true
			end
		end
	end
	
	if foundCar then
		if CurCarMaxWeight != nil then
		--	RunConsoleCommand("pnrp_OpenCarInventory")
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

--concommand.Add( "pnrp_carinv", GM.car_inventory_window )

--EOF