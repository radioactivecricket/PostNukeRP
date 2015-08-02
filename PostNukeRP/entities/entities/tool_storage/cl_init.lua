include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

function StorageHUDLabel()
	local myPlayer = LocalPlayer()
	
	local tracedata = {}
	tracedata.start = myPlayer:GetShootPos()
	tracedata.endpos = tracedata.start + (myPlayer:GetAimVector() * 1000)
	tracedata.filter = myPlayer
	local trace = util.TraceLine(tracedata)
	
	if !trace.Entity:IsValid() then return end
	
	if trace.Entity:GetClass() == "tool_storage" then
		local font = "CenterPrintText"
		local text = trace.Entity:GetNetVar("name", "")
		surface.SetFont(font)
		local tWidth, tHeight = surface.GetTextSize(text)
		
		draw.WordBox( 8, (ScrW() / 2) - (8 + (tWidth / 2)), (ScrH() / 2) - (16 + tHeight), text, font, Color(50,50,75,100), Color(255,255,255,255) )
	end
end
hook.Add( "HUDPaint", "StorageHUDLabel", StorageHUDLabel )

function StorageSelectMenu( len )
	local ply = LocalPlayer()
	
	local storageENT = net.ReadEntity()
	local storage_table = net.ReadTable()
	
	local w = 810
	local h = 520
	local title = "Storage Selection Menu"
		
	local storagemenu_frame = vgui.Create( "DFrame" )
		storagemenu_frame:SetSize( w, h ) 
		storagemenu_frame:SetPos( ScrW() / 2 - storagemenu_frame:GetWide() / 2, ScrH() / 2 - storagemenu_frame:GetTall() / 2 )
		storagemenu_frame:SetTitle( "" )
		storagemenu_frame:SetVisible( true )
		storagemenu_frame:SetDraggable( false )
		storagemenu_frame:ShowCloseButton( true )
		storagemenu_frame:MakePopup()
		storagemenu_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", storagemenu_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_4b.png" )
			screenBG:SetKeepAspect()
			screenBG:SizeToContents()
			screenBG:SetSize(storagemenu_frame:GetWide(), storagemenu_frame:GetTall())
			
		local ToolName = vgui.Create( "DLabel", storagemenu_frame )
			ToolName:SetPos(60,40)
			ToolName:SetColor(Color( 0, 255, 0, 255 ))
			ToolName:SetText( title )
			ToolName:SizeToContents()
		
		local pnlList = vgui.Create("DPanelList", storagemenu_frame)
			pnlList:SetPos(50, 60)
			pnlList:SetSize(storagemenu_frame:GetWide() - 400, storagemenu_frame:GetTall() - 120)
			pnlList:EnableVerticalScrollbar(true) 
			pnlList:EnableHorizontal(false) 
			pnlList:SetSpacing(1)
			pnlList:SetPadding(10)
			pnlList.Paint = function()
			
			end
			
			for k, v in pairs(storage_table) do
				local pnlPanel = vgui.Create("DPanel")
					pnlPanel:SetTall(75)
					pnlPanel.Paint = function()
						draw.RoundedBox( 6, 0, 0, pnlPanel:GetWide(), pnlPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
					end
					pnlList:AddItem(pnlPanel)
					
					pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
					pnlPanel.Icon:SetModel(storageENT:GetModel())
					pnlPanel.Icon:SetPos(3, 5)
					pnlPanel.Icon:SetToolTip( "Click to select this storage" )
					pnlPanel.Icon.DoClick = function()
						net.Start("SetStorage")
							net.WriteEntity(ply)
							net.WriteEntity(storageENT)
							net.WriteDouble(storage_table[k]["storageid"])
							net.WriteString(storage_table[k]["name"])
						net.SendToServer()
						storagemenu_frame:Close()
					end	
					
					pnlPanel.Title = vgui.Create("DLabel", pnlPanel)
					pnlPanel.Title:SetPos(90, 5)
					pnlPanel.Title:SetText(storage_table[k]["name"])
					pnlPanel.Title:SetColor(Color( 0, 0, 0, 255 ))
					pnlPanel.Title:SizeToContents() 
					pnlPanel.Title:SetContentAlignment( 5 )
					
					local storageRes = storage_table[k]["res"]
					local vendScrap = 0
					local vendSP = 0
					local vendChems = 0
					
					if string.len(tostring(storageRes)) > 3 then
						local resSplit = string.Explode( ",", storageRes )
						if table.Count( resSplit ) > 1 then
							vendScrap = resSplit[1]
							vendSP = resSplit[2]
							vendChems = resSplit[3]
						end
					end
						
					pnlPanel.Resources = vgui.Create("DLabel", pnlPanel)
					pnlPanel.Resources:SetPos(90, 20)
					pnlPanel.Resources:SetText("")
					pnlPanel.Resources:SetColor(Color( 0, 0, 0, 255 ))
					pnlPanel.Resources:SizeToContents() 
					pnlPanel.Resources:SetContentAlignment( 5 )

					
					if storage_table[k]["inventory"] != NULL and string.len(tostring(storage_table[k]["inventory"])) > 4 then
						pnlPanel.Inventory = vgui.Create("DLabel", pnlPanel)
						pnlPanel.Inventory:SetPos(90, 35)
						pnlPanel.Inventory:SetText("Inventory: Has Inventory")
						pnlPanel.Inventory:SetColor(Color( 0, 0, 0, 255 ))
						pnlPanel.Inventory:SizeToContents() 
						pnlPanel.Inventory:SetContentAlignment( 5 )
					else
						pnlPanel.Inventory = vgui.Create("DLabel", pnlPanel)
						pnlPanel.Inventory:SetPos(90, 35)
						pnlPanel.Inventory:SetText("Inventory: Empty")
						pnlPanel.Inventory:SetColor(Color( 0, 0, 0, 255 ))
						pnlPanel.Inventory:SizeToContents() 
						pnlPanel.Inventory:SetContentAlignment( 5 )
					end
					
					pnlPanel.DelStorageBtn = vgui.Create("DButton", pnlPanel )
					pnlPanel.DelStorageBtn:SetPos(90, 53)
					pnlPanel.DelStorageBtn:SetSize(100,18)
					pnlPanel.DelStorageBtn:SetText( "Rename Storage" )
					pnlPanel.DelStorageBtn.DoClick = function()
						renameStorage( storageENT, storage_table[k]["storageid"], storage_table[k]["name"] )
						storagemenu_frame:Close()
					end
					
					pnlPanel.DelStorageBtn = vgui.Create("DButton", pnlPanel )
					pnlPanel.DelStorageBtn:SetPos(200, 53)
					pnlPanel.DelStorageBtn:SetSize(100,18)
					pnlPanel.DelStorageBtn:SetText( "Delete Storage" )
					pnlPanel.DelStorageBtn.DoClick = function()
						PNRP.OptionVerify( "deleteStorage", storage_table[k]["storageid"], nil, storagemenu_frame )
					end
			end
			
			
		--//Menu	
		local btnHPos = 50
		local btnWPos = storagemenu_frame:GetWide()-300
		local btnHeight = 35
		local lblColor = Color( 245, 218, 210, 180 )
		
		local newStorageLbl = vgui.Create("DLabel", storagemenu_frame)
			newStorageLbl:SetPos( btnWPos,btnHPos )
			newStorageLbl:SetColor( lblColor )
			newStorageLbl:SetText( "Storage Profile Menu" )
			newStorageLbl:SetFont("Trebuchet24")
			newStorageLbl:SizeToContents()	
			
		btnHPos = btnHPos + btnHeight + 10
		
		local newStorageBtn = vgui.Create("DImageButton", storagemenu_frame)
			newStorageBtn:SetPos( btnWPos,btnHPos )
			newStorageBtn:SetSize(30,30)
			newStorageBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			newStorageBtn.DoClick = function() 
				storagemenu_frame:Close()
				StorageNewMenu( storageENT )
			end
			newStorageBtn.Paint = function()
				if newStorageBtn:IsDown() then 
					newStorageBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					newStorageBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local newStorageBtnLbl = vgui.Create("DLabel", storagemenu_frame)
			newStorageBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
			newStorageBtnLbl:SetColor( lblColor )
			newStorageBtnLbl:SetText( "Create New Storage" )
			newStorageBtnLbl:SetFont("Trebuchet24")
			newStorageBtnLbl:SizeToContents()
		
		btnHPos = btnHPos + btnHeight + 40
		
		local infoStorageLbl = vgui.Create("DLabel", storagemenu_frame)
			infoStorageLbl:SetPos( btnWPos,btnHPos )
			infoStorageLbl:SetColor( lblColor )
			infoStorageLbl:SetText( "Setup Info:" )
			infoStorageLbl:SetFont("Trebuchet24")
			infoStorageLbl:SetWide(250)
			infoStorageLbl:SetTall(30)
			infoStorageLbl:SetWrap(true)	
		btnHPos = btnHPos + btnHeight
		local infoStorageLbl = vgui.Create("DLabel", storagemenu_frame)
			infoStorageLbl:SetPos( btnWPos,btnHPos )
			infoStorageLbl:SetColor( lblColor )
			infoStorageLbl:SetText( "1. Create new Storage Profile \n  (Press Create New Storage)" )
			infoStorageLbl:SetFont("HudHintTextLarge")
			infoStorageLbl:SetWide(250)
			infoStorageLbl:SetTall(30)
			infoStorageLbl:SetWrap(true)	
		btnHPos = btnHPos + btnHeight
		local infoStorageLbl = vgui.Create("DLabel", storagemenu_frame)
			infoStorageLbl:SetPos( btnWPos,btnHPos )
			infoStorageLbl:SetColor( lblColor )
			infoStorageLbl:SetText( "2. Click the Storage Icon to set the profile to the Storage" )
			infoStorageLbl:SetFont("HudHintTextLarge")
			infoStorageLbl:SetWide(250)
			infoStorageLbl:SetTall(30)
			infoStorageLbl:SetWrap(true)	
		btnHPos = btnHPos + btnHeight + 10
		local infoStorageLbl = vgui.Create("DLabel", storagemenu_frame)
			infoStorageLbl:SetPos( btnWPos,btnHPos )
			infoStorageLbl:SetColor( lblColor )
			infoStorageLbl:SetText( "Profiles can only be set to one Storage at a time" )
			infoStorageLbl:SetFont("HudHintTextLarge")
			infoStorageLbl:SetWide(250)
			infoStorageLbl:SetTall(30)
			infoStorageLbl:SetWrap(true)
		btnHPos = btnHPos + btnHeight + 5
		local infoStorageLbl = vgui.Create("DLabel", storagemenu_frame)
			infoStorageLbl:SetPos( btnWPos,btnHPos )
			infoStorageLbl:SetColor( lblColor )
			infoStorageLbl:SetText( "First Profile is free" )
			infoStorageLbl:SetFont("HudHintTextLarge")
			infoStorageLbl:SetWide(250)
			infoStorageLbl:SetTall(30)
			infoStorageLbl:SetWrap(true)
		btnHPos = btnHPos + btnHeight - 5
		local costStr = string.Explode( " ", PNRP.Items[storageENT:GetClass()].ProfileCost)
		local pScr = tostring(costStr[1])
		local pSP = tostring(costStr[2])
		local pChem = tostring(costStr[3])
		
		local infoStorageLbl = vgui.Create("DLabel", storagemenu_frame)
			infoStorageLbl:SetPos( btnWPos,btnHPos )
			infoStorageLbl:SetColor( lblColor )
			infoStorageLbl:SetText( "Cost per Profile: Scrap: "..pScr.." \n Small Parts: "..pSP.." Chemicals: "..pChem )
			infoStorageLbl:SetFont("HudHintTextLarge")
			infoStorageLbl:SetWide(250)
			infoStorageLbl:SetTall(30)
			infoStorageLbl:SetWrap(true)
		btnHPos = btnHPos + btnHeight + 10
		local infoStorageLbl = vgui.Create("DLabel", storagemenu_frame)
			infoStorageLbl:SetPos( btnWPos,btnHPos )
			infoStorageLbl:SetColor( lblColor )
			infoStorageLbl:SetText( "Warning:" )
			infoStorageLbl:SetFont("Trebuchet24")
			infoStorageLbl:SetWide(250)
			infoStorageLbl:SetTall(30)
			infoStorageLbl:SetWrap(true)	
		btnHPos = btnHPos + btnHeight
		local infoStorageLbl = vgui.Create("DLabel", storagemenu_frame)
			infoStorageLbl:SetPos( btnWPos,btnHPos )
			infoStorageLbl:SetColor( lblColor )
			infoStorageLbl:SetText( "All items in the storage profile will be lost when the profile is deleted" )
			infoStorageLbl:SetFont("HudHintTextLarge")
			infoStorageLbl:SetWide(250)
			infoStorageLbl:SetTall(30)
			infoStorageLbl:SetWrap(true)	
		

end
net.Receive("storage_select_menu", StorageSelectMenu)

function OpenStorageNewMenu( )
	local storageENT = net:ReadEntity()
	StorageNewMenu( storageENT )
end
function StorageNewMenu( storageENT )
	local ply = LocalPlayer()
		
	local w = 500
	local h = 150
	local title = "New Storage Menu"
		
	local storagemenu_frame = vgui.Create( "DFrame" )
		storagemenu_frame:SetSize( w, h ) 
		storagemenu_frame:SetPos( ScrW() / 2 - storagemenu_frame:GetWide() / 2, ScrH() / 2 - storagemenu_frame:GetTall() / 2 )
		storagemenu_frame:SetTitle( title )
		storagemenu_frame:SetVisible( true )
		storagemenu_frame:SetDraggable( false )
		storagemenu_frame:ShowCloseButton( true )
		storagemenu_frame:MakePopup()
					
		local SetNameLbl = vgui.Create( "DLabel", storagemenu_frame )
			SetNameLbl:SetPos(60,60)
			SetNameLbl:SetColor(Color( 0, 255, 0, 255 ))
			SetNameLbl:SetText( "Storage Name" )
			SetNameLbl:SizeToContents()
		local setNameTxt = vgui.Create("DTextEntry", storagemenu_frame)
			setNameTxt:SetText(ply:Nick().."'s Storage")
			setNameTxt:SetPos(150,62)
			setNameTxt:SetWide(300)
		local buttonNewStorage = vgui.Create( "DButton", storagemenu_frame )
			buttonNewStorage:SetSize( 150, 25 )
			buttonNewStorage:SetPos( 150, 90 )
			buttonNewStorage:SetText( "Create new Storage" )
			buttonNewStorage.DoClick = function( )
				local name = setNameTxt:GetValue()
				net.Start("CreateNewStorage")
					net.WriteEntity(ply)
					net.WriteEntity(storageENT)
					net.WriteString(name)
				net.SendToServer()
				storagemenu_frame:Close()
			end

end
net.Receive("storage_new_menu", OpenStorageNewMenu)

local storagemenu_frame
local storagemenu_body
function StorageMenu()
	local ply = LocalPlayer()
	
	local storageENT = net:ReadEntity()
	local storageID = net.ReadString()
	local inventory_table = net.ReadTable()
	local plyInventoryTble = net.ReadTable()
	local avModels = net.ReadTable()
	local storageHealth = net.ReadDouble()
	local PlayerInvWeight = net.ReadString()
	local CurInvWeight = net.ReadString()
	local weightCap = net.ReadString()
	local capacity = net.ReadString()
	
	if not storagemenu_frame or tostring(storagemenu_frame) == "[NULL Panel]" then
		storagemenu_frame = PNRP.PNRP_Frame()
		if not storagemenu_frame then return end
		
		local w = 810
		local h = 520
		
		storagemenu_frame:SetSize( w, h ) 
			storagemenu_frame:SetPos( ScrW() / 2 - storagemenu_frame:GetWide() / 2, ScrH() / 2 - storagemenu_frame:GetTall() / 2 )
			storagemenu_frame:SetTitle( "" )
			storagemenu_frame:SetVisible( true )
			storagemenu_frame:SetDraggable( false )
			storagemenu_frame:ShowCloseButton( true )
			storagemenu_frame:MakePopup()
			storagemenu_frame.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
			
			local screenBG = vgui.Create("DImage", storagemenu_frame)
				screenBG:SetImage( "VGUI/gfx/pnrp_screen_5b.png" )
				screenBG:SetKeepAspect()
				screenBG:SizeToContents()
				screenBG:SetSize(storagemenu_frame:GetWide(), storagemenu_frame:GetTall())			
	end
	
	buildPlyStoragePanels(storageENT, storageID, inventory_table,plyInventoryTble,PlayerInvWeight,CurInvWeight,weightCap,capacity)	
	
	--//Storage Status			
	local lMenuList = vgui.Create( "DPanelList", storagemenu_frame )
		lMenuList:SetPos( 610,45 )
		lMenuList:SetSize( 150, 175 )
		lMenuList:SetSpacing( 5 )
		lMenuList:SetPadding(3)
		lMenuList:EnableHorizontal( false ) 
		lMenuList:EnableVerticalScrollbar( true ) 

		local storagemenuLabel = vgui.Create("DLabel", storagemenu_frame)
			storagemenuLabel:SetColor( Color( 255, 255, 255, 255 ) )
			storagemenuLabel:SetText( "Storage Menu" )
			storagemenuLabel:SetFont("Trebuchet24")
			storagemenuLabel:SizeToContents()
			lMenuList:AddItem( storagemenuLabel )

		local NameLabel = vgui.Create("DLabel")
			NameLabel:SetColor( Color( 255, 255, 255, 255 ) )
			NameLabel:SetText( " Storage Status" )
			NameLabel:SizeToContents()
			lMenuList:AddItem( NameLabel )
		local LDevide = vgui.Create("DShape") 
			LDevide:SetParent( stockStatusList ) 
			LDevide:SetType("Rect")
			LDevide:SetSize( 100, 2 ) 	
			lMenuList:AddItem( LDevide )
			
		local hpCVar = 255
		hpCVar = 255-(((100 - storageHealth)/storageHealth)*255)
		
		local hpColor = Color( 255, hpCVar, hpCVar, 255 )
		
		local LHPLabel = vgui.Create("DLabel")
			LHPLabel:SetColor( hpColor )
			LHPLabel:SetText( " Health: "..storageHealth.."%" )
			LHPLabel:SizeToContents()
			lMenuList:AddItem( LHPLabel )
		local LCPLabel = vgui.Create("DLabel")
			LCPLabel:SetColor( Color( 255, 255, 255, 255 ) )
			LCPLabel:SetText( " Capacity: "..capacity )
			LCPLabel:SizeToContents()
			lMenuList:AddItem( LCPLabel )
		
		--//Storage Owner Menu Menu	
		local btnHPos = 250
		local btnWPos = storagemenu_frame:GetWide()-220
		local btnHeight = 40
		local lblColor = Color( 245, 218, 210, 180 )
						
		local vendRenameBtn = vgui.Create("DImageButton", storagemenu_frame)
			vendRenameBtn:SetPos( btnWPos,btnHPos )
			vendRenameBtn:SetSize(30,30)
			vendRenameBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			vendRenameBtn.DoClick = function() 
				renameStorage( storageENT, storage_table[1]["storageid"], storage_table[1]["name"] )
				storagemenu_frame:Close()
			end
			vendRenameBtn.Paint = function()
				if vendRenameBtn:IsDown() then 
					vendRenameBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					vendRenameBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local vendRenameBtnLbl = vgui.Create("DLabel", storagemenu_frame)
			vendRenameBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
			vendRenameBtnLbl:SetColor( lblColor )
			vendRenameBtnLbl:SetText( "Rename Storage" )
			vendRenameBtnLbl:SetFont("Trebuchet24")
			vendRenameBtnLbl:SizeToContents()
		
		btnHPos = btnHPos + btnHeight			
		local chModelBtn = vgui.Create("DImageButton", storagemenu_frame)
			chModelBtn:SetPos( btnWPos,btnHPos )
			chModelBtn:SetSize(30,30)
			chModelBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			chModelBtn.DoClick = function() 
				changeStorageModelMenu(storageENT, avModels)
				storagemenu_frame:Close()
			end
			chModelBtn.Paint = function()
				if chModelBtn:IsDown() then 
					chModelBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					chModelBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local chModelBtnLbl = vgui.Create("DLabel", storagemenu_frame)
			chModelBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
			chModelBtnLbl:SetColor( lblColor )
			chModelBtnLbl:SetText( "Change Model" )
			chModelBtnLbl:SetFont("Trebuchet24")
			chModelBtnLbl:SizeToContents()
		
		btnHPos = btnHPos + btnHeight			
		local repBtn = vgui.Create("DImageButton", storagemenu_frame)
			repBtn:SetPos( btnWPos,btnHPos )
			repBtn:SetSize(30,30)
			if storageHealth < 100 then
				repBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				repBtn.DoClick = function() 
					net.Start("StorageRepair")
						net.WriteEntity(ply)
						net.WriteEntity(storageENT)
					net.SendToServer()
					storagemenu_frame:Close()
				end
		
				repBtn.Paint = function()
					if repBtn:IsDown() then 
						repBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						repBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end	
			else
				repBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
			end	
		local repBtnLbl = vgui.Create("DLabel", storagemenu_frame)
			repBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
			repBtnLbl:SetColor( lblColor )
			repBtnLbl:SetText( "Repair Storage" )
			repBtnLbl:SetFont("Trebuchet24")
			repBtnLbl:SizeToContents()
		
		btnHPos = btnHPos + btnHeight			
		local remBtn = vgui.Create("DImageButton", storagemenu_frame)
			remBtn:SetPos( btnWPos,btnHPos )
			remBtn:SetSize(30,30)
			remBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			remBtn.DoClick = function() 
				PNRP.OptionVerify( "pnrp_remstorage", tostring(storageENT:GetNetVar("storageid")), nil ) 
				storagemenu_frame:Close()
			end
			remBtn.Paint = function()
				if remBtn:IsDown() then 
					remBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					remBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local remBtnLbl = vgui.Create("DLabel", storagemenu_frame)
			remBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
			remBtnLbl:SetColor( lblColor )
			remBtnLbl:SetText( "Remove Storage" )
			remBtnLbl:SetFont("Trebuchet24")
			remBtnLbl:SizeToContents()
end

function buildPlyStoragePanels(storageENT, storageID, inventory_table,plyInventoryTble,PlayerInvWeight,CurInvWeight,weightCap,capacity)	
		if not storagemenu_frame then return end
		if storagemenu_body then storagemenu_body:Remove() end
		
		local stoItem = PNRP.Items[itemID]
		
		storagemenu_body = vgui.Create( "DPanel", storagemenu_frame )
			storagemenu_body:SetPos( 0, 0 ) -- Set the position of the panel
			storagemenu_body:SetSize( storagemenu_frame:GetWide()-50, storagemenu_frame:GetTall())
			storagemenu_body.Paint = function() end
		
		local invWeightText = "Weight: "..tostring(CurInvWeight).."/"..tostring(capacity).."\n"
		local yourWeightText = "Weight:"..tostring(PlayerInvWeight).."/"..tostring(weightCap)
		local invWeightColor = Color( 0, 255, 0, 255 )
		local yourWeightColor = Color( 0, 255, 0, 255 )
		
		if tonumber(CurInvWeight) >= tonumber(capacity) then
			invWeightColor = Color( 255, 0, 0, 255 )
		end
		if tonumber(PlayerInvWeight) >= tonumber(weightCap) then
			yourWeightColor = Color( 255, 0, 0, 255 )
		end
					
		local paneWidth = 255
		
		--//Storage Inventory
		local StorageInvLabel = vgui.Create( "DLabel", storagemenu_body )
			StorageInvLabel:SetText("Storage Inventory")
			StorageInvLabel:SetPos(35, 40)
			StorageInvLabel:SetColor( Color( 0, 255, 0, 255 ) )
			StorageInvLabel:SizeToContents()
		local InvWeight = vgui.Create("DLabel", storagemenu_body)
			InvWeight:SetPos(190, 40 )
			InvWeight:SetText(invWeightText)
			InvWeight:SetColor(invWeightColor)
			InvWeight:SizeToContents()
		local pnlLIList = vgui.Create("DPanelList", storagemenu_body)
			pnlLIList:SetPos(30, 55)
			pnlLIList:SetSize(paneWidth, storagemenu_body:GetTall() - 111)
			pnlLIList:EnableVerticalScrollbar(true) 
			pnlLIList:EnableHorizontal(false) 
			pnlLIList:SetSpacing(1)
			pnlLIList:SetPadding(5)
			
		--Generates the Storage's inventory
		if inventory_table == nil then
			local EmptyLabel = vgui.Create( "DLabel" )
				EmptyLabel:SetText("Storage Inventory is Empty")
				EmptyLabel:SetColor( Color( 0, 255, 0, 255 ) )
				EmptyLabel:SizeToContents()
				
				pnlLIList:AddItem(EmptyLabel)
		else
			for k, v in pairs( inventory_table ) do
				local item = PNRP.Items[v["itemid"]]
				if item then
					local pnlPanel = vgui.Create("DPanel")
						pnlPanel:SetTall(75)
						pnlPanel.Paint = function()
							draw.RoundedBox( 1, 0, 0, pnlPanel:GetWide(), 1, Color( 0, 255, 0, 80 ) )
							draw.RoundedBox( 1, 0, pnlPanel:GetTall()-1, pnlPanel:GetWide(), 1, Color( 0, 255, 0, 80 ) )
						end
						pnlLIList:AddItem(pnlPanel)
						
						local model = item.Model
						local skin = 0
						local Info = item.Info
						local countTxt = "Count: "..tostring(v["count"])
						if v["status_table"] != "" then
							countTxt = ""
							local HP = PNRP.GetFromStat(v["status_table"], "HP")
							if HP then 	countTxt = "HP: "..HP end
							local PowerLevel = PNRP.GetFromStat(v["status_table"], "PowerLevel")
							if PowerLevel then 	countTxt = countTxt.." Charge: "..tostring(math.Round(PowerLevel/100)).."% " end
							local FuelLevel = PNRP.GetFromStat(v["status_table"], "FuelLevel")
							if FuelLevel then countTxt = countTxt.." Fuel: "..tostring(FuelLevel) end
							local GasLevel = PNRP.GetFromStat(v["status_table"], "Gas")
							if GasLevel then countTxt = countTxt.." Gas: "..tostring(math.Round(100-((item.Tank-GasLevel)/item.Tank)*100)).."% " end
							
							local newModel = PNRP.GetFromStat(v["status_table"], "Model")
							local newSkin = PNRP.GetFromStat(v["status_table"], "Skin")
							if newModel then model = newModel end
							if newSkin then skin = tonumber(newSkin) end
						end
													
						pnlPanel.Title = vgui.Create("DLabel", pnlPanel)
						pnlPanel.Title:SetPos(70, 5)
						pnlPanel.Title:SetText(item.Name)
						pnlPanel.Title:SetColor(Color( 0, 255, 0, 255 ))
						pnlPanel.Title:SizeToContents() 
						pnlPanel.Title:SetContentAlignment( 5 )
						
						local weightTXT = "Weight: "..item.Weight
						if item.Capacity then
							weightTXT = weightTXT.." | Capacity: "..item.Capacity
						end
						pnlPanel.ItemWeight = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.ItemWeight:SetPos(70, 55)
						pnlPanel.ItemWeight:SetText(weightTXT)
						pnlPanel.ItemWeight:SetColor(Color( 0, 200, 0, 255 ))
						pnlPanel.ItemWeight:SizeToContents() 
						pnlPanel.ItemWeight:SetContentAlignment( 5 )
						
						pnlPanel.Count = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.Count:SetPos(70, 40)
						pnlPanel.Count:SetText(countTxt)
						pnlPanel.Count:SetColor(Color( 0, 255, 0, 255 ))
						pnlPanel.Count:SizeToContents() 
						pnlPanel.Count:SetContentAlignment( 5 )
						
						pnlPanel.bulkSlider = vgui.Create( "DNumSlider", pnlPanel )
						pnlPanel.bulkSlider:SetPos(5, 15) 
						pnlPanel.bulkSlider:SetWide( 240 )
						pnlPanel.bulkSlider:SetText( "" )
						pnlPanel.bulkSlider:SetMin( 1 )
						pnlPanel.bulkSlider:SetMax( v["count"] )
						pnlPanel.bulkSlider:SetDecimals( 0 )
						pnlPanel.bulkSlider:SetValue( 1 )
						pnlPanel.bulkSlider:Hide()
						pnlPanel.bulkSlider.Label:SizeToContents()
						
						if item.Type == "food" or item.Type == "medical" or item.Type == "weapon" or item.Type == "ammo" then
							local useBtn = vgui.Create("DButton", pnlPanel )
								useBtn:SetPos(70, 20)
								useBtn:SetSize(35,17)
								useBtn:SetText( "Use" )
								useBtn.DoClick = function() 
									net.Start("UseFromPlyStoreage")
										net.WriteEntity(storageENT)
										net.WriteString("storage")
										net.WriteString(item.ID)
									net.SendToServer() 
								end
						end
						
						if v["iid"] == "" and v["count"] > 1 then
							pnlPanel.bulkSlider:Show()
						end 
						
						local toolTip = nil
						if tostring(item.Info) ~= "" then toolTip = tostring(item.Info) end
						pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
						pnlPanel.Icon:SetModel(model, skin)
						pnlPanel.Icon:SetPos(3, 5)
						pnlPanel.Icon:SetToolTip( toolTip )
						pnlPanel.Icon.DoClick = function()
							local weightCur = CurInvWeight + item.Weight
							local weightBlk
							local weightCapBlk
							local amt = pnlPanel.bulkSlider:GetValue()
							
							--Idiot ammount check
							if amt <= 0 then amt = 1 end
							if amt >= v["count"] then amt = v["count"] end
							
							if amt >= 1 then								
								net.Start("storage_take")
									net.WriteEntity(storageENT)
									net.WriteString(item.ID)
									net.WriteDouble(amt)
									net.WriteString(v["iid"])
								net.SendToServer()
							else
								ply:ChatPrint("Your pack is to full.")
							end
						end
				end
			end
		end
			
		--//Player Inventory
		local PlayerInvLabel = vgui.Create( "DLabel", storagemenu_body )
			PlayerInvLabel:SetText("Player  Inventory")
			PlayerInvLabel:SetPos(320, 40)
			PlayerInvLabel:SetColor( Color( 0, 255, 0, 255 ) )
			PlayerInvLabel:SizeToContents()
		local yourWeight = vgui.Create("DLabel", storagemenu_body)
			yourWeight:SetPos(475, 40 )
			yourWeight:SetText(yourWeightText)
			yourWeight:SetColor(yourWeightColor)
			yourWeight:SizeToContents() 
			
		local pnlUserIList = vgui.Create("DPanelList", storagemenu_body)
			pnlUserIList:SetPos(315, 55)
			pnlUserIList:SetSize(paneWidth, storagemenu_body:GetTall() - 111)
			pnlUserIList:EnableVerticalScrollbar(true) 
			pnlUserIList:EnableHorizontal(false) 
			pnlUserIList:SetSpacing(1)
			pnlUserIList:SetPadding(5)
		--Generates the user's inventory
		if plyInventoryTble == nil then
			local EmptyLabel = vgui.Create( "DLabel", storagemenu_body )
				EmptyLabel:SetText("Player Inventory is Empty")
				EmptyLabel:SetColor( Color( 0, 255, 0, 255 ) )
				EmptyLabel:SizeToContents()
				
				pnlUserIList:AddItem(EmptyLabel)
		else
			for k, v in pairs( plyInventoryTble ) do
				local item = PNRP.Items[v["itemid"]]
				if item then
					local pnlPanel = vgui.Create("DPanel")
						pnlPanel:SetTall(75)
						pnlPanel.Paint = function()
							draw.RoundedBox( 1, 0, 0, pnlPanel:GetWide(), 1, Color( 0, 255, 0, 80 ) )
							draw.RoundedBox( 1, 0, pnlPanel:GetTall()-1, pnlPanel:GetWide(), 1, Color( 0, 255, 0, 80 ) )
						end
						pnlUserIList:AddItem(pnlPanel)
						
						local model = item.Model
						local skin = 0
						local Info = item.Info
						local countTxt = "Count: "..tostring(v["count"])
						if v["status_table"] != "" then
							countTxt = ""
							local HP = PNRP.GetFromStat(v["status_table"], "HP")
							if HP then 	countTxt = "HP: "..HP end
							local PowerLevel = PNRP.GetFromStat(v["status_table"], "PowerLevel")
							if PowerLevel then 	countTxt = countTxt.." Charge: "..tostring(math.Round(PowerLevel/100)).."% " end
							local FuelLevel = PNRP.GetFromStat(v["status_table"], "FuelLevel")
							if FuelLevel then countTxt = countTxt.." Fuel: "..tostring(FuelLevel) end
							local GasLevel = PNRP.GetFromStat(v["status_table"], "Gas")
							if GasLevel then countTxt = countTxt.." Gas: "..tostring(math.Round(100-((item.Tank-GasLevel)/item.Tank)*100)).."% " end
							
							local newModel = PNRP.GetFromStat(v["status_table"], "Model")
							local newSkin = PNRP.GetFromStat(v["status_table"], "Skin")
							if newModel then model = newModel end
							if newSkin then skin = tonumber(newSkin) end
						end
													
						pnlPanel.Title = vgui.Create("DLabel", pnlPanel)
						pnlPanel.Title:SetPos(70, 5)
						pnlPanel.Title:SetText(item.Name)
						pnlPanel.Title:SetColor(Color( 0, 255, 0, 255 ))
						pnlPanel.Title:SizeToContents() 
						pnlPanel.Title:SetContentAlignment( 5 )
						
						local weightTXT = "Weight: "..item.Weight
						if item.Capacity then
							weightTXT = weightTXT.." | Capacity: "..item.Capacity
						end
						pnlPanel.ItemWeight = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.ItemWeight:SetPos(70, 55)
						pnlPanel.ItemWeight:SetText(weightTXT)
						pnlPanel.ItemWeight:SetColor(Color( 0, 200, 0, 255 ))
						pnlPanel.ItemWeight:SizeToContents() 
						pnlPanel.ItemWeight:SetContentAlignment( 5 )
						
						pnlPanel.Count = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.Count:SetPos(70, 40)
						pnlPanel.Count:SetText(countTxt)
						pnlPanel.Count:SetColor(Color( 0, 255, 0, 255 ))
						pnlPanel.Count:SizeToContents() 
						pnlPanel.Count:SetContentAlignment( 5 )
						
						pnlPanel.bulkSlider = vgui.Create( "DNumSlider", pnlPanel )
						pnlPanel.bulkSlider:SetPos(0, 15) 
						pnlPanel.bulkSlider:SetWide( 250 )
						pnlPanel.bulkSlider:SetText( "" )
						pnlPanel.bulkSlider:SetMin( 1 )
						pnlPanel.bulkSlider:SetMax( v["count"] )
						pnlPanel.bulkSlider:SetDecimals( 0 )
						pnlPanel.bulkSlider:SetValue( 1 )
						pnlPanel.bulkSlider:Hide()
						pnlPanel.bulkSlider.Label:SizeToContents()
						
						if item.Type == "food" or item.Type == "medical" or item.Type == "weapon" or item.Type == "ammo" then
							local useBtn = vgui.Create("DButton", pnlPanel )
								useBtn:SetPos(70, 20)
								useBtn:SetSize(35,17)
								useBtn:SetText( "Use" )
								useBtn.DoClick = function() 
									net.Start("UseFromPlyStoreage")
										net.WriteEntity(storageENT)
										net.WriteString("player")
										net.WriteString(item.ID)
									net.SendToServer() 
								end
						end
						
						if v["iid"] == "" and v["count"] > 1 then
							pnlPanel.bulkSlider:Show()
						end 
						
						local toolTip = nil
						if tostring(item.Info) ~= "" then toolTip = tostring(item.Info) end
						pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
						pnlPanel.Icon:SetModel(model, skin)
						pnlPanel.Icon:SetPos(3, 5)
						pnlPanel.Icon:SetToolTip( toolTip )
						pnlPanel.Icon.DoClick = function()
							local weightCur = CurInvWeight + item.Weight
							local weightBlk
							local weightCapBlk
							local amt = pnlPanel.bulkSlider:GetValue()
							
							--Idiot ammount check
							if amt <= 0 then amt = 1 end
							if amt >= v["count"] then amt = v["count"] end
														
							if amt >= 1 then
								net.Start("storage_give")
									net.WriteEntity(storageENT)
									net.WriteString(item.ID)
									net.WriteDouble(amt)
									net.WriteString(v["iid"])
								net.SendToServer()
							else
								ply:ChatPrint("Not enough storage space.")
							end
						end
				end
			end
		end	
end
net.Receive("storage_menu", StorageMenu)

function changeStorageModelMenu(storageENT, avModels)
	local ply = LocalPlayer()
	
	local w = 710
	local h = 520
	local title = "Select a new model"
		
	local storagemenu_frame = vgui.Create( "DFrame" )
		storagemenu_frame:SetSize( w, h ) 
		storagemenu_frame:SetPos( ScrW() / 2 - storagemenu_frame:GetWide() / 2, ScrH() / 2 - storagemenu_frame:GetTall() / 2 )
		storagemenu_frame:SetTitle( "" )
		storagemenu_frame:SetVisible( true )
		storagemenu_frame:SetDraggable( false )
		storagemenu_frame:ShowCloseButton( true )
		storagemenu_frame:MakePopup()
		storagemenu_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
	
		local screenBG = vgui.Create("DImage", storagemenu_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_2b.png" )
			screenBG:SetKeepAspect()
			screenBG:SizeToContents()
			screenBG:SetSize(storagemenu_frame:GetWide(), storagemenu_frame:GetTall())
		
		local paneWidth = 255
		
		local StorageLabel = vgui.Create( "DLabel", storagemenu_frame )
			StorageLabel:SetText(title)
			StorageLabel:SetPos(55, 40)
			StorageLabel:SetColor( Color( 0, 255, 0, 255 ) )
			StorageLabel:SizeToContents()
			
		local pnlLIList = vgui.Create("DPanelList", storagemenu_frame)
			pnlLIList:SetPos(50, 55)
			pnlLIList:SetSize(paneWidth, storagemenu_frame:GetTall() - 111)
			pnlLIList:EnableVerticalScrollbar(false) 
			pnlLIList:EnableHorizontal(true) 
			pnlLIList:SetSpacing(1)
			pnlLIList:SetPadding(5)
			
			for _, model in pairs( avModels ) do
				vendIcon = vgui.Create("SpawnIcon", pnlLIList)
				vendIcon:SetModel(model)
				vendIcon:SetToolTip( "Set Model: "..model )
				vendIcon.DoClick = function() 
					net.Start("ChangeStorageModel")
						net.WriteEntity(ply)
						net.WriteEntity(storageENT)
						net.WriteString(model)
					net.SendToServer()
					storagemenu_frame:Close()
				end	
				pnlLIList:AddItem(vendIcon)
			end
end

function renameStorage( storageENT, storageid, name )
	local ply = LocalPlayer()
		
	local w = 500
	local h = 150
	local title = "Rename Storage Menu"
		
	name = tostring(name)
	
	local storagemenu_frame = vgui.Create( "DFrame" )
		storagemenu_frame:SetSize( w, h ) 
		storagemenu_frame:SetPos( ScrW() / 2 - storagemenu_frame:GetWide() / 2, ScrH() / 2 - storagemenu_frame:GetTall() / 2 )
		storagemenu_frame:SetTitle( title )
		storagemenu_frame:SetVisible( true )
		storagemenu_frame:SetDraggable( false )
		storagemenu_frame:ShowCloseButton( true )
		storagemenu_frame:MakePopup()
					
		local SetNameLbl = vgui.Create( "DLabel", storagemenu_frame )
			SetNameLbl:SetPos(60,60)
			SetNameLbl:SetColor(Color( 0, 255, 0, 255 ))
			SetNameLbl:SetText( "Storage Name" )
			SetNameLbl:SizeToContents()
		local setNameTxt = vgui.Create("DTextEntry", storagemenu_frame)
			setNameTxt:SetText(name)
			setNameTxt:SetPos(150,62)
			setNameTxt:SetWide(300)
		local renameBtn = vgui.Create( "DButton", storagemenu_frame )
			renameBtn:SetSize( 150, 25 )
			renameBtn:SetPos( 150, 90 )
			renameBtn:SetText( "Rename Storage" )
			renameBtn.DoClick = function( )
				local name = setNameTxt:GetValue()
				net.Start("StorageRename")
					net.WriteEntity(ply)
					net.WriteEntity(storageENT)
					net.WriteDouble(storageid)
					net.WriteString(name)
				net.SendToServer()
				storagemenu_frame:Close()
			end
end

local function StorageBreakInBar ()
	surface.SetDrawColor( 0, 0, 0, 100)
	surface.DrawRect(ScrW()/2 - 50 , ScrH()/2, 100, 25 )
	
	local percentage = ((CurTime() - StartTime) + (60 - TimeLeft)) / 60
	
	surface.SetDrawColor( 0, 155, 0, 255 )
	surface.DrawOutlinedRect(ScrW()/2 - 50 , ScrH()/2, 100, 25 )
	surface.DrawRect(ScrW()/2 - 50 , ScrH()/2, 100*percentage, 25 )
end

local function StorageRepairBar ()
	surface.SetDrawColor( 0, 0, 0, 100)
	surface.DrawRect(ScrW()/2 - 50 , ScrH()/2, 100, 25 )
	
	local percentage = ( (60 - TimeLeft) - (CurTime() - StartTime) )  / 60
	
	surface.SetDrawColor( 0, 155, 0, 255 )
	surface.DrawOutlinedRect(ScrW()/2 - 50 , ScrH()/2, 100, 25 )
	surface.DrawRect(ScrW()/2 - 50 , ScrH()/2, 100*percentage, 25 )
end

function StorageBreakIn( )
	local storageENT = net:ReadEntity()
	local length = net:ReadDouble()
	local ply = LocalPlayer()
	StartTime = CurTime()
	TimeLeft = length
	
	hook.Add( "HUDPaint", "StorageBreakInBar", StorageBreakInBar )
	
	net.Start("storage_breakin")
		net.WriteEntity(ply)
		net.WriteEntity(storageENT)
	net.SendToServer()
end
net.Receive("storage_breakin", StorageBreakIn)

function StorageStopBreakIn( data )
	hook.Remove( "HUDPaint", "StorageBreakInBar")
end
net.Receive("storage_stopbreakin", StorageStopBreakIn)

function StorageRepair( )
	local storage = net:ReadEntity()
	local length = net:ReadDouble()
	
	StartTime = CurTime()
	TimeLeft = length
	
	hook.Add( "HUDPaint", "StorageRepairBar", StorageRepairBar )
end
net.Receive("storage_repair", StorageRepair)

function StorageStopRepair( data )
	hook.Remove( "HUDPaint", "StorageRepairBar")
end
net.Receive("storage_stoprepair", StorageStopRepair)
