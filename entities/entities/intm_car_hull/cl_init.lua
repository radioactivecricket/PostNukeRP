include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

function OpenHullRecCh()
	local ply = LocalPlayer()
	local hullEnt = net.ReadEntity()
	local resAmount = net.ReadDouble()
	local hasScav = net.ReadString()
	
	local canHull = true
	if tostring(hasScav) == "true" or tonumber(resAmount) < 50 then
		canHull = false
	end
	
	HullRes_frame = PNRP.PNRP_Frame()
	if not HullRes_frame then return end
	
	HullRes_frame:SetSize( 575, 265 ) 
	HullRes_frame:SetPos(ScrW() / 2 - HullRes_frame:GetWide() / 2, ScrH() / 2 - HullRes_frame:GetTall() / 2)
	HullRes_frame:SetTitle( " " )
	HullRes_frame:SetVisible( true )
	HullRes_frame:SetDraggable( false )
	HullRes_frame:ShowCloseButton( true )
	HullRes_frame:MakePopup()
	HullRes_frame.Paint = function() 
		surface.SetDrawColor( 50, 50, 50, 0 )
	end
	
	local screenBG = vgui.Create("DImage", HullRes_frame)
		screenBG:SetImage( "VGUI/gfx/pnrp_screen_6b.png" )
		screenBG:SetSize(HullRes_frame:GetWide(), HullRes_frame:GetTall())	
		
	local HullResBody_Frame = vgui.Create( "DPanel", HullRes_frame )
		HullResBody_Frame:SetPos( 30, 20 ) -- Set the position of the panel
		HullResBody_Frame:SetSize( HullRes_frame:GetWide() - 250, HullRes_frame:GetTall() - 40)
		HullResBody_Frame.Paint = function() end
	
		local hull_Icon = vgui.Create("SpawnIcon", HullResBody_Frame)
			hull_Icon:SetSize( 100, 100 )
			hull_Icon:SetModel(hullEnt:GetModel(), hullEnt:GetSkin())
			hull_Icon:SetPos(10, 10)
			hull_Icon:SetToolTip( nil )
			hull_Icon.DoClick = function() end
		local hull_Label = vgui.Create("DLabel", HullResBody_Frame)
			hull_Label:SetPos(135, 35)
			hull_Label:SetText("Old rusty car body")
			hull_Label:SetFont("Trebuchet18")
			hull_Label:SetColor(Color( 0, 255, 0, 255 ))
			hull_Label:SizeToContents() 
			hull_Label:SetContentAlignment( 5 )
			
		local sPerc = resAmount.."%"
		local hpTxt = "Hull: "..sPerc
		local hullStatus_Label = vgui.Create("DLabel", HullRes_frame)
			hullStatus_Label:SetPos(HullRes_frame:GetWide()-200, 50)
			hullStatus_Label:SetFont("Trebuchet18")
			hullStatus_Label:SetText(hpTxt)
			hullStatus_Label:SetColor(Color( 0, 255, 0, 255 ))
			hullStatus_Label:SizeToContents() 
			hullStatus_Label:SetContentAlignment( 5 )
			
		local hsTxt = ""
		if tostring(hasScav) == "true" then hsTxt = "Someone has already started\n salvaging this for parts." 
		elseif resAmount < 50 then hsTxt = "Body too damaged to recover"
		elseif canHull then hsTxt = "A Car Body can be salvaged\n from this" end
		local hullInfo_Label = vgui.Create("DLabel", HullRes_frame)
			hullInfo_Label:SetPos(HullRes_frame:GetWide()-200, 75)
			hullInfo_Label:SetText(hsTxt)
			hullInfo_Label:SetColor(Color( 0, 255, 0, 255 ))
			hullInfo_Label:SizeToContents() 
			hullInfo_Label:SetContentAlignment( 5 )
			
		local btnHPos = 155
		local btnHeight = 50
		local lblColor = Color( 245, 218, 210, 180 )
		local btnWide = HullRes_frame:GetWide()-220		
		
		local canScavParts = false
		local btnTxt = "Salvage for Resources"
		if ply:Team() == TEAM_ENGINEER or ply:Team() == TEAM_SCAVENGER then
			canScavParts = true
			btnTxt = "Salvage for Parts"
		end
		
		local salScrapBtn = vgui.Create("DImageButton", HullRes_frame)
			salScrapBtn:SetPos( btnWide,btnHPos )
			salScrapBtn:SetSize(30,30)
			salScrapBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			salScrapBtn.DoClick = function() 
				 net.Start("SND_CL_SalvageHull")
					net.WriteEntity(hullEnt)
					net.WriteString("salvage")
				 net.SendToServer()
				 
				 HullRes_frame:Close()
			end	
			salScrapBtn.Paint = function()
				if salScrapBtn:IsDown() then 
					salScrapBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					salScrapBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end
		local salScrapBtnLbl = vgui.Create("DLabel", HullRes_frame)
			salScrapBtnLbl:SetPos( btnWide+45,btnHPos+2 )
			salScrapBtnLbl:SetColor( lblColor )
			salScrapBtnLbl:SetText( btnTxt )
			salScrapBtnLbl:SetFont("Trebuchet24")
			salScrapBtnLbl:SizeToContents()	
			
		btnHPos = btnHPos + btnHeight
		local salHullBtn = vgui.Create("DImageButton", HullRes_frame)
			salHullBtn:SetPos( btnWide,btnHPos )
			salHullBtn:SetSize(30,30)
			
			if ply:Team() == TEAM_ENGINEER and canHull then
				salHullBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				salHullBtn.DoClick = function()
					net.Start("SND_CL_SalvageHull")
						net.WriteEntity(hullEnt)
						net.WriteString("hull")
					net.SendToServer()
				 
					HullRes_frame:Close()
				end
				salHullBtn.Paint = function()
					if salHullBtn:IsDown() then 
						salHullBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						salHullBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end
				
			else
				salHullBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
			end
		local salHullBtnLbl = vgui.Create("DLabel", HullRes_frame)
			salHullBtnLbl:SetPos( btnWide+45,btnHPos+2 )
			salHullBtnLbl:SetColor( lblColor )
			salHullBtnLbl:SetText( "Recover Hull" )
			salHullBtnLbl:SetFont("Trebuchet24")
			salHullBtnLbl:SizeToContents()
			
		btnHPos = btnHPos + btnHeight
		
end
net.Receive("pnrp_OpenHullRecCh", OpenHullRecCh)

function BuildACarMenu()
	local ply = LocalPlayer()
	local hullEnt = net.ReadEntity()
	local carTbl = net.ReadTable()
	local plyInv = net.ReadTable()
	
	local canBuild = false
	
	HullBuild_frame = PNRP.PNRP_Frame()
	if not HullBuild_frame then return end
	
	HullBuild_frame:SetSize( 575, 265 ) 
	HullBuild_frame:SetPos(ScrW() / 2 - HullBuild_frame:GetWide() / 2, ScrH() / 2 - HullBuild_frame:GetTall() / 2)
	HullBuild_frame:SetTitle( " " )
	HullBuild_frame:SetVisible( true )
	HullBuild_frame:SetDraggable( false )
	HullBuild_frame:ShowCloseButton( true )
	HullBuild_frame:MakePopup()
	HullBuild_frame.Paint = function() 
		surface.SetDrawColor( 50, 50, 50, 0 )
	end
	
	local screenBG = vgui.Create("DImage", HullBuild_frame)
		screenBG:SetImage( "VGUI/gfx/pnrp_screen_6b.png" )
		screenBG:SetSize(HullBuild_frame:GetWide(), HullBuild_frame:GetTall())	
	
	local hull_Label = vgui.Create("DLabel", HullBuild_frame)
		hull_Label:SetPos(HullBuild_frame:GetWide()-205, 35)
		hull_Label:SetText("Selected: None")
		hull_Label:SetFont("Trebuchet18")
		hull_Label:SetColor(Color( 0, 255, 0, 255 ))
		hull_Label:SizeToContents() 
		hull_Label:SetContentAlignment( 5 )	
		
	local HullResBody_Panel = vgui.Create( "DPanel", HullBuild_frame )
		HullResBody_Panel:SetPos( 30, 30 ) -- Set the position of the panel
		HullResBody_Panel:SetSize( HullBuild_frame:GetWide() - 275, HullBuild_frame:GetTall() - 60)
		HullResBody_Panel.Paint = function() end
		
		local selCar
		local ToolScrollPanel
		local Scroller = vgui.Create("DHorizontalScroller", HullResBody_Panel) --Create the scroller
			Scroller:SetSize(HullResBody_Panel:GetWide()-8, 135)
			Scroller:AlignTop(2)
			Scroller:AlignLeft(2)
			Scroller:SetOverlap(-1)
			
			for k, v in pairs(carTbl) do
				local Item = PNRP.Items[v]
				local pnlPanel = vgui.Create("DPanel", Scroller)
					pnlPanel:SetSize( 125,125 )
					pnlPanel.Paint = function() end
					
					local icon
				if Item.EntName then
					icon = vgui.Create( "ContentIcon", pnlPanel )
					icon:SetSize( pnlPanel:GetWide(), pnlPanel:GetTall() )
					icon:SetMaterial( "entities/"..Item.EntName..".png" )
					icon:SetName( Item.Name )
					icon:SetToolTip( nil )
					icon.DoClick = function()
						selectCar(Item)
					end
				else
					icon = vgui.Create( "SpawnIcon", pnlPanel )
					icon:SetSize( pnlPanel:GetWide(), pnlPanel:GetTall() )
					icon:SetModel( Item.Model )
					icon:SetToolTip( Item.Name )
					icon.DoClick = function()
						selectCar(Item)
					end
				end
				Scroller:AddPanel(pnlPanel)
			end
	
		local btnHPos = 155
		local btnHeight = 50
		local lblColor = Color( 245, 218, 210, 180 )
		local btnWide = HullBuild_frame:GetWide()-220		
				
		local BuildACarBtn = vgui.Create("DImageButton", HullBuild_frame)
			BuildACarBtn:SetPos( btnWide,btnHPos )
			BuildACarBtn:SetSize(30,30)
			BuildACarBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
			
		local BuildACarBtnLbl = vgui.Create("DLabel", HullBuild_frame)
			BuildACarBtnLbl:SetPos( btnWide+45,btnHPos+2 )
			BuildACarBtnLbl:SetColor( lblColor )
			BuildACarBtnLbl:SetText( "Build Vehicle" )
			BuildACarBtnLbl:SetFont("Trebuchet24")
			BuildACarBtnLbl:SizeToContents()
			
		local TM_Label = vgui.Create("DLabel", HullBuild_frame)
			TM_Label:SetPos(HullBuild_frame:GetWide()-200, 60)
			TM_Label:SetText("")
			TM_Label:SetFont("Trebuchet18")
			TM_Label:SetColor(Color( 0, 255, 0, 255 ))
			TM_Label:SizeToContents() 
			TM_Label:SetContentAlignment( 5 )
			
		local EngWar_Label = vgui.Create("DLabel", HullBuild_frame)
			EngWar_Label:SetPos(HullBuild_frame:GetWide()-205, 105)
			EngWar_Label:SetFont("Trebuchet18")
			EngWar_Label:SetColor(Color( 0, 255, 0, 255 ))
			EngWar_Label:SetText("")
			EngWar_Label:SizeToContents() 
			EngWar_Label:SetContentAlignment( 5 )
			
	function selectCar(theItem)
		canBuild = true
		hull_Label:SetText("Build: "..theItem.Name)
		hull_Label:SizeToContents()
		selCar = theItem.ID
		
		if ToolScrollPanel then ToolScrollPanel:Remove() end
		
		local buildOption = "external"
		
		if ply:Team() == TEAM_ENGINEER then
			if theItem.Scrap != nil then sc = math.ceil( theItem.Scrap * (1 - (0.02 * ply:GetSkill("Construction"))))  else sc = 0 end
			if theItem.SmallParts != nil then sp = math.ceil(theItem.SmallParts * (1 - (0.02 * ply:GetSkill("Construction")))) else sp = 0 end
			if theItem.Chemicals != nil then ch = math.ceil(theItem.Chemicals * (1 - (0.02 * ply:GetSkill("Construction")))) else ch = 0 end
		else
			if theItem.Scrap != nil then sc = theItem.Scrap else sc = 0 end
			if theItem.SmallParts != nil then sp = theItem.SmallParts else sp = 0 end
			if theItem.Chemicals != nil then ch = theItem.Chemicals else ch = 0 end
		end
		
		local costTxt = "Scrap "..tostring(sc).." SP "..tostring(sp).." Chems "..tostring(ch)
		
		EngWar_Label:SetText(costTxt)
		EngWar_Label:SizeToContents()

		ToolScrollPanel = vgui.Create("DPanel", HullBuild_frame)
			ToolScrollPanel:SetSize( HullResBody_Panel:GetWide()-8, 50 )
			ToolScrollPanel:SetPos( 35, HullResBody_Panel:GetTall()-30 )
			ToolScrollPanel.Paint = function() end	
		
		local toolcheck = theItem.ToolCheck( ply )
		
		local ToolExtScroller = vgui.Create("DHorizontalScroller", ToolScrollPanel) --Create the scroller
			ToolExtScroller:SetSize(ToolScrollPanel:GetWide(), ToolScrollPanel:GetTall())
			ToolExtScroller:AlignTop(0)
			ToolExtScroller:AlignLeft(0)
			ToolExtScroller:SetOverlap(-1)
			
			local toolExtMissing = false
			local foundItems = PNRP.FindNearbyItems( hullEnt )
			
			for k, v in pairs(toolcheck) do
				local toolItem = PNRP.Items[k]
				
				local tEColor = Color( 180, 180, 180, 0 )
				if toolItem then
					if (not foundItems) or (not foundItems[k]) or foundItems[k] < v then
						tEColor = Color( 180, 0, 0, 50 )
						toolExtMissing = true
					end
				
					local pnlTPanel = vgui.Create("DPanel", ToolExtScroller)
						pnlTPanel:SetSize( 50,50 )
						pnlTPanel.Paint = function() 
							draw.RoundedBox( 6, 0, 0, pnlTPanel:GetWide(), pnlTPanel:GetTall(), tEColor )		
						end
					local toolIcon = vgui.Create( "SpawnIcon", pnlTPanel )
						toolIcon:SetSize( pnlTPanel:GetWide(), pnlTPanel:GetTall() )
						toolIcon:SetModel( toolItem.Model )
						toolIcon:SetToolTip( toolItem.Name.." x"..tostring(v) )
						toolIcon.DoClick = function() end
					ToolExtScroller:AddPanel(pnlTPanel)
				end
			end
		
		local ToolPlyScroller = vgui.Create("DHorizontalScroller", ToolScrollPanel) --Create the scroller
			ToolPlyScroller:SetSize(ToolScrollPanel:GetWide(), ToolScrollPanel:GetTall())
			ToolPlyScroller:AlignBottom(0)
			ToolPlyScroller:AlignLeft(0)
			ToolPlyScroller:SetOverlap(-1)
			ToolPlyScroller:Hide()
			
			local toolPlyMissing = false

			for k, v in pairs(toolcheck) do
				local toolItem = PNRP.Items[k]
				
				local tColor = Color( 180, 180, 180, 0 )
				if toolItem then
					if (not plyInv) or (not plyInv[k]) or plyInv[k] < v then
						tColor = Color( 180, 0, 0, 50 )
						toolPlyMissing = true
					end
				
					local pnlTPPanel = vgui.Create("DPanel", ToolPlyScroller)
						pnlTPPanel:SetSize( 50,50 )
						pnlTPPanel.Paint = function() 
							draw.RoundedBox( 6, 0, 0, pnlTPPanel:GetWide(), pnlTPPanel:GetTall(), tColor )		
						end
					local toolPIcon = vgui.Create( "SpawnIcon", pnlTPPanel )
						toolPIcon:SetSize( pnlTPPanel:GetWide(), pnlTPPanel:GetTall() )
						toolPIcon:SetModel( toolItem.Model )
						toolPIcon:SetToolTip( toolItem.Name.." x-"..tostring(v) )
						toolPIcon.DoClick = function() end
					ToolPlyScroller:AddPanel(pnlTPPanel)
				end
			end
			
		local extInv_Btn = vgui.Create("DButton", HullBuild_frame )
			extInv_Btn:SetPos(35, 155)
			extInv_Btn:SetSize(100,17)
			extInv_Btn:SetText( "Near by Parts" ) 
			extInv_Btn.DoClick = function()
				ToolPlyScroller:Hide()
				ToolExtScroller:Show()
				buildOption = "external"
				
				toolChk(toolExtMissing)
			end
		local plyInv_Btn = vgui.Create("DButton", HullBuild_frame )
			plyInv_Btn:SetPos(136, 155)
			plyInv_Btn:SetSize(100,17)
			plyInv_Btn:SetText( "Parts from Inv" ) 
			plyInv_Btn.DoClick = function()
				ToolPlyScroller:Show()
				ToolExtScroller:Hide()
				buildOption = "player"
				
				toolChk(toolPlyMissing)
			end
			
		function toolChk(toolMissing)
			if toolMissing then				
				TM_Label:SetText("Unable to Build \nMissing needed parts")
				TM_Label:SizeToContents() 
				canBuild = false
			else
				TM_Label:SetText("")
				TM_Label:SizeToContents() 
				canBuild = true
			end
			
			if ply:Team() ~= TEAM_ENGINEER and not (ply:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1) 
				then canBuild = false 
			end
		
			if BuildACarBtn then BuildACarBtn:Remove() end
			BuildACarBtn = vgui.Create("DImageButton", HullBuild_frame)
			BuildACarBtn:SetPos( btnWide,btnHPos )
			BuildACarBtn:SetSize(30,30)
			BuildACarBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				if canBuild then
					BuildACarBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					BuildACarBtn.DoClick = function() 
						 net.Start("SND_CL_HullToCar")
							net.WriteEntity(hullEnt)
							net.WriteString(selCar)
							net.WriteString(buildOption)
						 net.SendToServer()
						 
						 HullBuild_frame:Close()
					end	
					BuildACarBtn.Paint = function()
						if BuildACarBtn:IsDown() then 
							BuildACarBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						else
							BuildACarBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
						end
					end
				else
					BuildACarBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				end
		end
		
		toolChk(toolExtMissing)
				
	end
	
	if ply:Team() ~= TEAM_ENGINEER and not (ply:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1) then
		EngWar_Label:SetText("Must be Engineer to build")
		EngWar_Label:SizeToContents() 
	end
	
	
end
net.Receive("pnrp_OpenBuildACarMenu", BuildACarMenu)