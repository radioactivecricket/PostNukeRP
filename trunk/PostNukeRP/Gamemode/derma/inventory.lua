--Build Inventory Window

--MyInventory = {}
local CurCarInvWeight
local inventory_frame

--function GM.inventory_window(ply)
function GM.inventory_window( handler, id, encoded, decoded )
	local MyInventory = decoded[1]		
	local CurWeight = decoded[2]	
	CurCarInvWeight = decoded[3]
	local ply = LocalPlayer()	
	inventory_frame = vgui.Create( "DFrame" )
		inventory_frame:SetSize( 700, 700 ) --Set the size
		inventory_frame:SetPos(ScrW() / 2 - inventory_frame:GetWide() / 2, ScrH() / 2 - inventory_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
		inventory_frame:SetTitle( "Inventory Menu" ) --Set title
		inventory_frame:SetVisible( true )
		inventory_frame:SetDraggable( true )
		inventory_frame:ShowCloseButton( true )
		inventory_frame:MakePopup()
		
		PNRP.buildMenu(inventory_frame)
		
	local PropertySheet = vgui.Create( "DPropertySheet" )
			PropertySheet:SetParent( inventory_frame )
			PropertySheet:SetPos( 5, 50 )
			PropertySheet:SetSize( inventory_frame:GetWide() - 10 , inventory_frame:GetTall() - 60 )
			PropertySheet:SetFadeTime( 0.5 )
			
			local weaponPanel = PNRP.build_inv_List(ply, "weapon", inventory_frame, PropertySheet, MyInventory)
			local ammoPanel = PNRP.build_inv_List(ply, "ammo", inventory_frame, PropertySheet, MyInventory)
			local medicalPanel = PNRP.build_inv_List(ply, "medical", inventory_frame, PropertySheet, MyInventory)
			local foodPanel = PNRP.build_inv_List(ply, "food", inventory_frame, PropertySheet, MyInventory)
			local vehiclePanel = PNRP.build_inv_List(ply, "vehicle", inventory_frame, PropertySheet, MyInventory)
			local toolsPanel = PNRP.build_inv_List(ply, "tool", inventory_frame, PropertySheet, MyInventory)
						
			PropertySheet:AddSheet( "Weapons", weaponPanel, "gui/silkicons/bomb", false, false, "Build Weapons" )
			PropertySheet:AddSheet( "Ammo", ammoPanel, "gui/silkicons/box", false, false, "Create Ammo" )
			PropertySheet:AddSheet( "Medical", medicalPanel, "gui/silkicons/heart", false, false, "Medical Items" )
			PropertySheet:AddSheet( "Food and Drink", foodPanel, "gui/silkicons/brick_add", false, false, "Food and Drink Items" )
			PropertySheet:AddSheet( "Vehicles", vehiclePanel, "gui/silkicons/car", false, false, "Create Vehicles" )
			PropertySheet:AddSheet( "Tools", toolsPanel, "gui/silkicons/wrench", false, false, "Make Tools - Still in Development" )
	
	local InvWeight = vgui.Create("DLabel", inventory_frame)		
			InvWeight:SetPos(570, 55 )
			local maxWeight
			if ply:Team() == TEAM_SCAVENGER then
				maxWeight = GetConVar("pnrp_packCapScav"):GetInt()
			else
				maxWeight = GetConVar("pnrp_packCap"):GetInt()
			end
			InvWeight:SetText("Current Weight: "..tostring(CurWeight).."/"..tostring(maxWeight))
--			InvWeight:SetColor(Color( 0, 0, 0, 255 ))
			InvWeight:SizeToContents() 
end

function PNRP.build_inv_List(ply, itemtype, parent_frame, PropertySheet, MyInventory)

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
				for k, v in pairs( MyInventory ) do
		
					if string.lower(k) == string.lower(itemname) then
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
								RunConsoleCommand("inventory_drop", itemname)
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
				 		
				 		if item.Type == "food" or item.Type == "medical" or item.Type == "weapon" or item.Type == "ammo" then
					 		pnlPanel.salvageItem = vgui.Create("DButton", pnlPanel )
							pnlPanel.salvageItem:SetPos(200, 55)
					 		pnlPanel.salvageItem:SetSize(100,17)
					    	pnlPanel.salvageItem:SetText( "Use Item" )
					    	pnlPanel.salvageItem.DoClick = function() 
					    		datastream.StreamToServer( "UseFromInv", {item.ID, 1} ) 
					    		parent_frame:Close() 
					    	end
					    end
				 		
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
				 		
				 		if itemtype != "vehicle" then
				 		
					    	for k,v in pairs(ents.FindInSphere( ply:GetPos(), 200 )) do
								local ItemID = PNRP.FindItemID( v:GetClass() )
								if ItemID != nil then
									local myType = PNRP.Items[ItemID].Type
									if tostring(v:GetNetworkedString( "Owner" , "None" )) == ply:Nick() && myType == "vehicle" then
									
										pnlPanel.sendCarInv = vgui.Create("DButton", pnlPanel )
								 		pnlPanel.sendCarInv:SetPos(450, 55)
								 		pnlPanel.sendCarInv:SetSize(100,18)
								    	pnlPanel.sendCarInv:SetText( "Send to Car Inv" )
--								    	pnlPanel.sendCarInv:SizeToContents() 
								    	pnlPanel.sendCarInv.DoClick = function()
								    		
								    		local weight = CurCarInvWeight + item.Weight
											local weightCap
											
											
											weightCap = PNRP.Items[ItemID].Weight
											
											if weight <= weightCap then
												RunConsoleCommand("pnrp_addtocarinentory",item.ID)
												parent_frame:Close()
											else
												parent_frame:Close()
												ply:ChatPrint("You're car trunk is full.")
											end
								    												
										end
									end
						
								end
					    	
					    	end
						end
						
						pnlPanel.salvageItem = vgui.Create("DButton", pnlPanel )
						pnlPanel.salvageItem:SetPos(555, 55)
				 		pnlPanel.salvageItem:SetSize(100,17)
				    	pnlPanel.salvageItem:SetText( "Salvage Item" )
				    	pnlPanel.salvageItem.DoClick = function() RunConsoleCommand("pnrp_dosalvage",item.ID) parent_frame:Close() end
				 	end
				end
			end
		end	
	
	return pnlList

end
datastream.Hook( "pnrp_OpenInvWindow", GM.inventory_window )

function GM.initInventory(ply)

	RunConsoleCommand("pnrp_OpenInventory")

end
concommand.Add( "pnrp_inv",  GM.initInventory )
--concommand.Add( "pnrp_inv",  GM.inventory_window )

--EOF