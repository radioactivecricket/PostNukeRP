local loadin_Frame
local sFrame = false

local initialLoad = false

local basicload_Frame
function basicLoadWindow( ply )
	local plyHasLoaded = ply:GetNetVar( "HasLoaded" , false )
	if plyHasLoaded then return end
	
	basicload_Frame = vgui.Create( "DFrame" )
		basicload_Frame:SetSize( 315, 140 ) 
		basicload_Frame:SetPos(ScrW() / 2 - basicload_Frame:GetWide() / 2, ScrH() / 2 - basicload_Frame:GetTall() / 2)
		basicload_Frame:SetTitle( " " )
		basicload_Frame:SetVisible( true )
		basicload_Frame:SetDraggable( false )
		basicload_Frame:ShowCloseButton( false )
		basicload_Frame.btnClose:SetVisible( false )
		basicload_Frame.btnMaxim:SetVisible( false )
		basicload_Frame.btnMinim:SetVisible( false )
		basicload_Frame:MakePopup()
		basicload_Frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
--		local myImage = vgui.Create("DImage", basicload_Frame)
--			myImage:SetImage( "VGUI/gfx/pnrp_screen_400x.png" )
--			--myImage:SizeToContents()
--			myImage:SetSize(basicload_Frame:GetWide(), basicload_Frame:GetTall())
		
		local loadinLabel_frame = vgui.Create( "DFrame" )
			loadinLabel_frame:SetParent( basicload_Frame )
			loadinLabel_frame:SetSize( 315, 40 ) 
			loadinLabel_frame:SetPos(ScrW() / 2 - basicload_Frame:GetWide() / 2, ScrH() / 2 - basicload_Frame:GetTall() / 2 - 15)
			loadinLabel_frame:SetTitle( " " )
			loadinLabel_frame:SetVisible( true )
			loadinLabel_frame:SetDraggable( false )
			loadinLabel_frame:ShowCloseButton( false )
			loadinLabel_frame.btnClose:SetVisible( false )
			loadinLabel_frame.btnMaxim:SetVisible( false )
			loadinLabel_frame.btnMinim:SetVisible( false )
			loadinLabel_frame:MakePopup()
			loadinLabel_frame.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
			
		local LoadinLabel = vgui.Create("DLabel", loadinLabel_frame)
			LoadinLabel:SetPos(10,0)
			LoadinLabel:SetColor( Color( 255, 255, 255, 255 ) )
			LoadinLabel:SetText( "Welcome to PostNukeRP" )
			LoadinLabel:SetFont("Trebuchet24")
			LoadinLabel:SizeToContents()
		--Inner Frame
		local Loadin_DPanel = vgui.Create( "DPanel" )
			Loadin_DPanel:SetParent( basicload_Frame )
			Loadin_DPanel:SetPos( 5, 25 )
			Loadin_DPanel:SetSize( basicload_Frame:GetWide() - 15, basicload_Frame:GetTall() - 55 )
			Loadin_DPanel.Paint = function() -- Paint function
				surface.SetDrawColor( 50, 50, 50, 255 ) 
				surface.DrawRect( 0, 0, Loadin_DPanel:GetWide(), Loadin_DPanel:GetTall() ) 
			end
			
			Loadin_DPanel.Welcome = vgui.Create("DLabel", Loadin_DPanel)
			Loadin_DPanel.Welcome:SetPos(10, 10)
			Loadin_DPanel.Welcome:SetText("Welcome to PostNukeRP [PNRP]")
			Loadin_DPanel.Welcome:SetColor( Color( 255, 255, 255, 255 ) )
			Loadin_DPanel.Welcome:SizeToContents() 
			Loadin_DPanel.Welcome:SetContentAlignment( 5 )
			
			Loadin_DPanel.Welcome2 = vgui.Create("DLabel", Loadin_DPanel)
			Loadin_DPanel.Welcome2:SetPos(10, 25)
			Loadin_DPanel.Welcome2:SetText("If you are new, please check the help menu for information.")
			Loadin_DPanel.Welcome2:SetColor( Color( 255, 255, 255, 255 ) )
			Loadin_DPanel.Welcome2:SizeToContents() 
			Loadin_DPanel.Welcome2:SetContentAlignment( 5 )
			
			Loadin_DPanel.help = vgui.Create("DButton") 
			Loadin_DPanel.help:SetParent( Loadin_DPanel ) 
			Loadin_DPanel.help:SetText( "Help Menu" ) 
			Loadin_DPanel.help:SetPos(10, 50)
			Loadin_DPanel.help:SetSize( 100, 20 ) 
			Loadin_DPanel.help.DoClick = function() 
				RunConsoleCommand( "pnrp_help")
			end	
			
			Loadin_DPanel.loadBtn = vgui.Create("DButton") 
			Loadin_DPanel.loadBtn:SetParent( Loadin_DPanel ) 
			Loadin_DPanel.loadBtn:SetText( "Start Playing!" ) 
			Loadin_DPanel.loadBtn:SetPos(115, 50)
			Loadin_DPanel.loadBtn:SetSize( 100, 20 ) 
			Loadin_DPanel.loadBtn.DoClick = function() 
				--datastream.StreamToServer( "loadPlayer", {} )
--				net.Start("loadPlayer")
				net.Start("initProfileStuff")
					net.WriteEntity(ply)
				net.SendToServer()
				basicload_Frame:Close()
			end	
	PNRP_motd()
end
concommand.Add( "pnrp_loadin",  basicLoadWindow )

local profilePicker_Frame
function GM.profilePicker( len )
	local ply = LocalPlayer()
	local plyResult = net.ReadTable()	

	profilePicker_Frame = vgui.Create( "DFrame" )
		profilePicker_Frame:SetSize( 700, 400 ) 
		profilePicker_Frame:SetPos(ScrW() / 2 - profilePicker_Frame:GetWide() / 2, ScrH() / 2 - profilePicker_Frame:GetTall() / 2)
		profilePicker_Frame:SetTitle( "Profile Picker" )
		profilePicker_Frame:SetVisible( true )
		profilePicker_Frame:SetDraggable( false )
		profilePicker_Frame:ShowCloseButton( false )
		profilePicker_Frame.btnClose:SetVisible( false )
		profilePicker_Frame:MakePopup()
			
			local PList_DPanel = vgui.Create( "DPanel" )
			PList_DPanel:SetParent( profilePicker_Frame )
			PList_DPanel:SetPos( 5, 25 )
			PList_DPanel:SetSize( profilePicker_Frame:GetWide() - 215, profilePicker_Frame:GetTall() - 35 )
			PList_DPanel.Paint = function() -- Paint function
				surface.SetDrawColor( 50, 50, 50, 255 ) 
				surface.DrawRect( 0, 0, PList_DPanel:GetWide(), PList_DPanel:GetTall() ) 
			end
			
			
			local Scroller = vgui.Create("DHorizontalScroller", PList_DPanel) --Create the scroller
			Scroller:SetSize(PList_DPanel:GetWide()-8, PList_DPanel:GetTall() - 10)
			Scroller:AlignBottom(5)
			Scroller:AlignLeft(4)
			Scroller:SetOverlap(-1) --Set how much to overlap, negative numbers will space out the panels.
			
			for k, v in pairs(plyResult) do
				local pnlPanel = vgui.Create("DPanel", Scroller)
					pnlPanel:SetSize( 115, PList_DPanel:GetTall() - 20 )
					pnlPanel.Paint = function()
						draw.RoundedBox( 6, 0, 0, pnlPanel:GetWide(), pnlPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
					end
					
					pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
					pnlPanel.Icon:SetModel(plyResult[k]["model"])
					pnlPanel.Icon:SetPos(pnlPanel:GetWide() / 2 - pnlPanel.Icon:GetWide() / 2, 5 )
					pnlPanel.Icon:SetToolTip( nil )
					pnlPanel.Icon.DoClick = function()	
						net.Start("loadPlayer")
							net.WriteEntity(ply)
							net.WriteString("old")
							net.WriteString(plyResult[k]["pid"]) --PID
						net.SendToServer()
						profilePicker_Frame:Close()
					end
					
					pnlPanel.Name = vgui.Create("DLabel", pnlPanel)		
					pnlPanel.Name:SetPos(5, 80)
					pnlPanel.Name:SetText(plyResult[k]["nick"])
					pnlPanel.Name:SetColor(Color( 0, 0, 0, 255 ))
					pnlPanel.Name:SizeToContents() 
					pnlPanel.Name:SetContentAlignment( 5 )
					
--					local communityName = ply:GetNWString("community", "N/A")
--					local communityTitle = ply:GetNWString("ctitle", "N/A")
					pnlPanel.Community = vgui.Create("DLabel", pnlPanel)		
					pnlPanel.Community:SetPos(5, 95)
					pnlPanel.Community:SetText("Community Name here\nCommunity Title")
					pnlPanel.Community:SetColor(Color( 0, 0, 0, 255 ))
					pnlPanel.Community:SizeToContents() 
					pnlPanel.Community:SetContentAlignment( 5 )
					
					pnlPanel.Class = vgui.Create("DLabel", pnlPanel)		
					pnlPanel.Class:SetPos(5, 125)
					pnlPanel.Class:SetText(team.GetName(tonumber(plyResult[k]["class"])))
					pnlPanel.Class:SetColor(team.GetColor(tonumber(plyResult[k]["class"])))
					pnlPanel.Class:SizeToContents() 
					pnlPanel.Class:SetContentAlignment( 5 )
					
					pnlPanel.XP = vgui.Create("DLabel", pnlPanel)		
					pnlPanel.XP:SetPos(5, 140)
					pnlPanel.XP:SetText("XP: "..plyResult[k]["xp"])
					pnlPanel.XP:SetColor(Color( 0, 0, 0, 255 ))
					pnlPanel.XP:SizeToContents() 
					pnlPanel.XP:SetContentAlignment( 5 )
					
					pnlPanel.LL = vgui.Create("DLabel", pnlPanel)		
					pnlPanel.LL:SetPos(5, 155)
					pnlPanel.LL:SetText("Last On:\n"..plyResult[k]["lastlog"])
					pnlPanel.LL:SetColor(Color( 0, 0, 0, 255 ))
					pnlPanel.LL:SizeToContents() 
					pnlPanel.LL:SetContentAlignment( 5 )
					
					pnlPanel.Stats = vgui.Create("DLabel", pnlPanel)		
					pnlPanel.Stats:SetPos(5, 190)
					pnlPanel.Stats:SetText("HP: "..plyResult[k]["health"].."\nArmor: "..plyResult[k]["armor"].."\nEnd: "..plyResult[k]["endurance"].."\nHunger: "..plyResult[k]["hunger"])
					pnlPanel.Stats:SetColor(Color( 0, 0, 0, 255 ))
					pnlPanel.Stats:SizeToContents() 
					pnlPanel.Stats:SetContentAlignment( 5 )
					
					local resStr = string.Explode( ",", plyResult[k]["res"] )
					pnlPanel.Res = vgui.Create("DLabel", pnlPanel)		
					pnlPanel.Res:SetPos(5, 255)
					pnlPanel.Res:SetText("Scrap:"..resStr[1].."\nSP:"..resStr[2].."\nChem:"..resStr[3])
					pnlPanel.Res:SetColor(Color( 0, 0, 0, 255 ))
					pnlPanel.Res:SizeToContents() 
					pnlPanel.Res:SetContentAlignment( 5 )
					
					pnlPanel.delBtn = vgui.Create("DButton", pnlPanel )
					pnlPanel.delBtn:SetPos(5, 315)
					pnlPanel.delBtn:SetSize(pnlPanel:GetWide() - 10,18)
					pnlPanel.delBtn:SetText( "Delete Profile" )
					pnlPanel.delBtn.DoClick = function()
						local dvParent = vgui.Create("DPanel", pnlPanel);
							dvParent:SetPos(5,280);
							dvParent:SetSize(pnlPanel:GetWide() - 10,65);
							dvParent:SetVisible(true);
								dvParent.VF = vgui.Create("DLabel", dvParent)		
								dvParent.VF:SetPos(5, 5)
								dvParent.VF:SetText("Are you sure?")
								dvParent.VF:SetColor(Color( 0, 0, 0, 255 ))
								dvParent.VF:SizeToContents() 
								dvParent.VF:SetContentAlignment( 5 )
								
								dvParent.delBtny = vgui.Create("DButton", dvParent )
								dvParent.delBtny:SetPos(5, 20)
								dvParent.delBtny:SetSize(dvParent:GetWide() - 10,18)
								dvParent.delBtny:SetText( "Yes" )
								dvParent.delBtny.DoClick = function()
									net.Start("delProfile")
										net.WriteEntity(ply)
										net.WriteString(plyResult[k]["pid"])
									net.SendToServer()
									profilePicker_Frame:Close()
								end
								dvParent.delBtnn = vgui.Create("DButton", dvParent )
								dvParent.delBtnn:SetPos(5, 40)
								dvParent.delBtnn:SetSize(dvParent:GetWide() - 10,18)
								dvParent.delBtnn:SetText( "No" )
								dvParent.delBtnn.DoClick = function()
									dvParent:SetVisible(false);
								end
					end	
				Scroller:AddPanel(pnlPanel)
			end			
			
		local selectedMdl = "models/player/kleiner.mdl"	
			
		--New Profile Section
		local newProfileLabel = vgui.Create("DLabel", profilePicker_Frame)
			newProfileLabel:SetPos(PList_DPanel:GetWide()+15,25)
			newProfileLabel:SetColor( Color( 255, 255, 255, 255 ) )
			newProfileLabel:SetText( "Create New Profile" )
			newProfileLabel:SizeToContents()
		
		local mdlIcon = vgui.Create("SpawnIcon", profilePicker_Frame)
			mdlIcon:SetModel("models/player/kleiner.mdl")
			mdlIcon:SetPos(PList_DPanel:GetWide()+15, 50 )
			mdlIcon:SetToolTip( nil )
			
		local mdlListView = vgui.Create( "DListView", profilePicker_Frame )
			mdlListView:SetPos( PList_DPanel:GetWide()+90, 50 )
			mdlListView:SetSize( 110, 150 )
			mdlListView:SetMultiSelect( false )
			mdlListView:AddColumn("Model")	
			mdlListView.OnClickLine = function(parent, line, isselected)
				mdlIcon:SetModel(line:GetValue(2))
				selectedMdl = line:GetValue(2)
				mdlListView:ClearSelection()
				mdlListView:SelectItem(line)
			end
			
			local mdlList = player_manager.AllValidModels( )
			local counter = 1
			for k, v in pairs( mdlList ) do
				mdlListView:AddLine( k, v )
				if k == "kleiner" then
					mdlListView:SelectItem(mdlListView:GetLine( counter ))
				end
				counter = counter + 1
			end
		
		local setClass = 1
		local classlListView = vgui.Create( "DListView", profilePicker_Frame )
			classlListView:SetPos( PList_DPanel:GetWide()+15, 210 )
			classlListView:SetSize( 185, 101 )
			classlListView:SetMultiSelect( false )
			classlListView:AddColumn("Classes")	
			classlListView.OnClickLine = function(parent, line, isselected)
				setClass = line:GetValue(2)
				classlListView:ClearSelection()
				classlListView:SelectItem(line)
			end
			
			local classList = team.GetAllTeams()
			for k, v in pairs( classList ) do
				if k > 0 && k < 10 then
					classlListView:AddLine( team.GetName(k), k )
				end
			end
			
			classlListView:SelectFirstItem( )
		
		local newProfileRPNLabel = vgui.Create("DLabel", profilePicker_Frame)
			newProfileRPNLabel:SetPos(PList_DPanel:GetWide()+15,315)
			newProfileRPNLabel:SetColor( Color( 255, 255, 255, 255 ) )
			newProfileRPNLabel:SetText( "To set RP Name: /rpname \nExample: /rpname \"bob\"\nFor more help press F1." )
			newProfileRPNLabel:SizeToContents()
		
		local loadBtn = vgui.Create("DButton") 
			loadBtn:SetParent( profilePicker_Frame ) 
			loadBtn:SetText( "Create New Player" ) 
			loadBtn:SetPos(PList_DPanel:GetWide()+15, 370)
			loadBtn:SetSize( 150, 20 ) 
			loadBtn.DoClick = function() 
				net.Start("loadPlayer")
					net.WriteEntity(ply)
					net.WriteString("new")
					net.WriteString(selectedMdl)
					net.WriteString(setClass)
				net.SendToServer()
				profilePicker_Frame:Close()
			end	
end
net.Receive("pnrp_runProfilePicker", GM.profilePicker)

function PNRP_motd()
	local w = 900
	local h = 770
	local title = "Paper Edit Window"
	
	local motd_frame = vgui.Create( "DFrame" )
		motd_frame:SetSize( w, h ) 
		motd_frame:SetPos( ScrW() / 2 - motd_frame:GetWide() / 2, ScrH() / 2 - motd_frame:GetTall() / 2 )
		motd_frame:SetTitle( "" )
		motd_frame:SetVisible( true )
		motd_frame:SetDraggable( false )
		motd_frame:ShowCloseButton( true )
		motd_frame:MakePopup()
		motd_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", motd_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_1b.png" )
			screenBG:SetKeepAspect()
			screenBG:SizeToContents()
			screenBG:SetSize(motd_frame:GetWide(), motd_frame:GetTall())
		
		local setTxt = vgui.Create("HTML", motd_frame)
			setTxt:SetMultiline(true)
			setTxt:OpenURL(PNRP_MOTDPath)
			setTxt:SetPos(50,40)
			setTxt:SetSize(motd_frame:GetWide()-100, motd_frame:GetTall()-100)
end
concommand.Add( "motd", PNRP_motd )
