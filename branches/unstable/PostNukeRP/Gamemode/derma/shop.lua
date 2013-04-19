--Build Shop Menu

local shop_frame
local shopFrameCK = false

function buy_shop()
	--Stops the multi window exploit
	if shopFrameCK then return end 
	shopFrameCK = true
	
	shop_frame = vgui.Create( "DFrame" )
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
			
	function shop_frame:Close()                  
		shopFrameCK = false                  
		self:SetVisible( false )                  
		self:Remove()          
	end 
end

function PNRP.build_List(itemtype, parent_frame, PropertySheet)

	local ply = LocalPlayer()
	local sc = 0
	local sp = 0
	local ch = 0
	
	local textColor = Color(200,200,200,255)
	local dListBKColor = Color(50,50,50,255)
	
	local pnlList = vgui.Create("DPanelList", PropertySheet)
		pnlList:SetPos(20, 80)
		pnlList:SetSize(parent_frame:GetWide() - 60, parent_frame:GetTall() - 120)
		pnlList:EnableVerticalScrollbar(true) 
		pnlList:EnableHorizontal(false) 
		pnlList:SetSpacing(1)
		pnlList:SetPadding(10)
		pnlList.Paint = function()
		--	draw.RoundedBox( 8, 0, 0, pnlList:GetWide(), pnlList:GetTall(), Color( 50, 50, 50, 255 ) )
		end
		
		for itemname, item in pairs(PNRP.Items) do
			if item.ShopHide == true and not (ply:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1)then
				--Do nothing
			else
				if item.Type == tostring( itemtype ) then
					
					local pnlPanel = vgui.Create("DPanel")
					pnlPanel:SetTall(75)
					pnlPanel.Paint = function()
						draw.RoundedBox( 6, 0, 0, pnlPanel:GetWide(), pnlPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
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
					pnlPanel.Title:SetColor(Color( 0, 0, 0, 255 ))
					pnlPanel.Title:SizeToContents() 
					pnlPanel.Title:SetContentAlignment( 5 )
															
					pnlPanel.Cost = vgui.Create("DLabel", pnlPanel)		
					pnlPanel.Cost:SetPos(90, 55)
					pnlPanel.Cost:SetText("Cost: Scrap "..tostring(sc).." | Small Parts "..tostring(sp).." | Chemicals "..tostring(ch))
					pnlPanel.Cost:SetColor(Color( 0, 0, 0, 255 ))
					pnlPanel.Cost:SizeToContents() 
					pnlPanel.Cost:SetContentAlignment( 5 )	
					
					pnlPanel.ClassBuild = vgui.Create("DLabel", pnlPanel)		
					pnlPanel.ClassBuild:SetPos(340, 5)
					pnlPanel.ClassBuild:SetText("Required Class for Creation: "..item.ClassSpawn)
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
					--	pnlList:AddItem( pnlPanel.bulkSlider )
						
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