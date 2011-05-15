local loadin_Frame
local sFrame = false

local initialLoad = false
require("datastream")

function GM.loadin_window( ply )
	if sFrame then return end 
	
	loadin_Frame = vgui.Create( "DFrame" )
		loadin_Frame:SetSize( 400, 450 ) 
		loadin_Frame:SetPos(ScrW() / 2 - loadin_Frame:GetWide() / 2, ScrH() / 2 - loadin_Frame:GetTall() / 2)
		loadin_Frame:SetTitle( " " )
		loadin_Frame:SetVisible( true )
		loadin_Frame:SetDraggable( false )
		loadin_Frame:ShowCloseButton( false )
		loadin_Frame:MakePopup()
		loadin_Frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
	
	local loadinLabel_frame = vgui.Create( "DFrame" )
		loadinLabel_frame:SetParent( loadin_Frame )
		loadinLabel_frame:SetSize( 250, 40 ) 
		loadinLabel_frame:SetPos(ScrW() / 2 - loadin_Frame:GetWide() / 2, ScrH() / 2 - loadin_Frame:GetTall() / 2 - 15)
		loadinLabel_frame:SetTitle( " " )
		loadinLabel_frame:SetVisible( true )
		loadinLabel_frame:SetDraggable( false )
		loadinLabel_frame:ShowCloseButton( false )
		loadinLabel_frame:MakePopup()
		loadinLabel_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local LoadinLabel = vgui.Create("DLabel", loadinLabel_frame)
			LoadinLabel:SetPos(10,0)
			LoadinLabel:SetColor( Color( 255, 255, 255, 255 ) )
			LoadinLabel:SetText( "Welcome to PostNukeRP[PNRP]" )
			LoadinLabel:SetFont("Trebuchet24")
			LoadinLabel:SizeToContents()
		--Inner Frame
		local Loadin_DPanel = vgui.Create( "DPanel" )
			Loadin_DPanel:SetParent( loadin_Frame )
			Loadin_DPanel:SetPos( 5, 25 )
			Loadin_DPanel:SetSize( loadin_Frame:GetWide() - 15, loadin_Frame:GetTall() - 55 )
			Loadin_DPanel.Paint = function() -- Paint function
				surface.SetDrawColor( 50, 50, 50, 255 ) 
				surface.DrawRect( 0, 0, Loadin_DPanel:GetWide(), Loadin_DPanel:GetTall() ) 
			end
		
		if initialLoad == false then
		
			Loadin_DPanel.Icon = vgui.Create("SpawnIcon", Loadin_DPanel)
			Loadin_DPanel.Icon:SetModel(ply:GetModel())
			Loadin_DPanel.Icon:SetPos(10, 10)
			Loadin_DPanel.Icon:SetToolTip( nil )
			
			Loadin_DPanel.Nick = vgui.Create("DLabel", Loadin_DPanel)
			Loadin_DPanel.Nick:SetPos(90, 10)
			Loadin_DPanel.Nick:SetText(ply:Nick())
			Loadin_DPanel.Nick:SetColor( Color( 255, 255, 255, 255 ) )
			Loadin_DPanel.Nick:SizeToContents() 
			Loadin_DPanel.Nick:SetContentAlignment( 5 )
			
			Loadin_DPanel.Team = vgui.Create("DLabel", Loadin_DPanel)
			Loadin_DPanel.Team:SetPos(90, 25)
			Loadin_DPanel.Team:SetText("Class: "..team.GetName(ply:Team()))
			Loadin_DPanel.Team:SetColor(team.GetColor(ply:Team()))
			Loadin_DPanel.Team:SizeToContents() 
			Loadin_DPanel.Team:SetContentAlignment( 5 )
			
			local MemberOf
			MemberOf = ply:GetNWString("community", "N/A")
			
			Loadin_DPanel.Community = vgui.Create("DLabel", Loadin_DPanel)
			Loadin_DPanel.Community:SetPos(90, 40)
			Loadin_DPanel.Community:SetText("Member of "..MemberOf)
			Loadin_DPanel.Community:SetColor( Color( 255, 255, 255, 255 ) )
			Loadin_DPanel.Community:SizeToContents() 
			Loadin_DPanel.Community:SetContentAlignment( 5 )
			
			Loadin_DPanel.XP = vgui.Create("DLabel", Loadin_DPanel)
			Loadin_DPanel.XP:SetPos(90, 60)
			Loadin_DPanel.XP:SetText("Current Experiance: "..GetXP())
			Loadin_DPanel.XP:SetColor( Color( 255, 255, 255, 255 ) )
			Loadin_DPanel.XP:SizeToContents() 
			Loadin_DPanel.XP:SetContentAlignment( 5 )
			
			Loadin_DPanel.Run = vgui.Create("DLabel", Loadin_DPanel)
			Loadin_DPanel.Run:SetPos(250, 20)
			Loadin_DPanel.Run:SetText("Run Speed: "..ply:GetRunSpeed( ))
			Loadin_DPanel.Run:SetColor( Color( 255, 255, 255, 255 ) )
			Loadin_DPanel.Run:SizeToContents() 
			Loadin_DPanel.Run:SetContentAlignment( 5 )
						
			local maxWeight
			if ply:Team() == TEAM_SCAVENGER then
				maxWeight = GetConVar("pnrp_packCapScav"):GetInt() + (GetSkill("Backpacking")*10)
			else
				maxWeight = GetConVar("pnrp_packCap"):GetInt() + (GetSkill("Backpacking")*10)
			end
			Loadin_DPanel.BackPk = vgui.Create("DLabel", Loadin_DPanel)
			Loadin_DPanel.BackPk:SetPos(250, 35)
			Loadin_DPanel.BackPk:SetText("Backpack Size: "..maxWeight)
			Loadin_DPanel.BackPk:SetColor( Color( 255, 255, 255, 255 ) )
			Loadin_DPanel.BackPk:SizeToContents() 
			Loadin_DPanel.BackPk:SetContentAlignment( 5 )
		
	else


	end
	
	--//Skills Main Menu
		local SkillMenu_frame = vgui.Create( "DFrame" )
			SkillMenu_frame:SetParent( loadin_Frame )
			SkillMenu_frame:SetSize( 100, Loadin_DPanel:GetTall() ) 
			SkillMenu_frame:SetPos( ScrW() / 2 + loadin_Frame:GetWide() / 2 + 5, ScrH() / 2 - loadin_Frame:GetTall() / 2 + 25)
			SkillMenu_frame:SetTitle( " " )
			SkillMenu_frame:SetVisible( true )
			SkillMenu_frame:SetDraggable( false )
			SkillMenu_frame:ShowCloseButton( false )
			SkillMenu_frame:MakePopup()
			SkillMenu_frame.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
			
			local loadinLabel_frame = vgui.Create( "DFrame" )
			loadinLabel_frame:SetParent( loadin_Frame )
			loadinLabel_frame:SetSize( 250, 40 ) 
			loadinLabel_frame:SetPos(ScrW() / 2 - loadin_Frame:GetWide() / 2, ScrH() / 2 - loadin_Frame:GetTall() / 2 - 15)
			loadinLabel_frame:SetTitle( " " )
			loadinLabel_frame:SetVisible( true )
			loadinLabel_frame:SetDraggable( false )
			loadinLabel_frame:ShowCloseButton( false )
			loadinLabel_frame:MakePopup()
			loadinLabel_frame.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
			
			local LoadinLabel = vgui.Create("DLabel", loadinLabel_frame)
				LoadinLabel:SetPos(10,0)
				LoadinLabel:SetColor( Color( 255, 255, 255, 255 ) )
				LoadinLabel:SetText( "Welcome to PostNukeRP[PNRP]" )
				LoadinLabel:SetFont("Trebuchet24")
				LoadinLabel:SizeToContents()
			--Inner Frame
			local Loadin_DPanel = vgui.Create( "DPanel" )
				Loadin_DPanel:SetParent( loadin_Frame )
				Loadin_DPanel:SetPos( 5, 25 )
				Loadin_DPanel:SetSize( loadin_Frame:GetWide() - 15, loadin_Frame:GetTall() - 55 )
				Loadin_DPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 255 ) 
					surface.DrawRect( 0, 0, Loadin_DPanel:GetWide(), Loadin_DPanel:GetTall() ) 
				end
			
				local createBtn = vgui.Create("DButton") 
					createBtn:SetParent( sMenuList ) 
					createBtn:SetText( "Exit" ) 
					createBtn:SetSize( 100, 20 ) 
					createBtn.DoClick = function() loadin_Frame:Close() end	
					sMenuList:AddItem( createBtn )
	
	function loadin_Frame:Close()                  
		sFrame = false                  
		self:SetVisible( false )                  
		self:Remove()          
	end 
end

local basicload_Frame
function basicLoadWindow( ply )
	basicload_Frame = vgui.Create( "DFrame" )
		basicload_Frame:SetSize( 315, 140 ) 
		basicload_Frame:SetPos(ScrW() / 2 - basicload_Frame:GetWide() / 2, ScrH() / 2 - basicload_Frame:GetTall() / 2)
		basicload_Frame:SetTitle( " " )
		basicload_Frame:SetVisible( true )
		basicload_Frame:SetDraggable( false )
		basicload_Frame:ShowCloseButton( false )
		basicload_Frame:MakePopup()
		basicload_Frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local loadinLabel_frame = vgui.Create( "DFrame" )
			loadinLabel_frame:SetParent( basicload_Frame )
			loadinLabel_frame:SetSize( 315, 40 ) 
			loadinLabel_frame:SetPos(ScrW() / 2 - basicload_Frame:GetWide() / 2, ScrH() / 2 - basicload_Frame:GetTall() / 2 - 15)
			loadinLabel_frame:SetTitle( " " )
			loadinLabel_frame:SetVisible( true )
			loadinLabel_frame:SetDraggable( false )
			loadinLabel_frame:ShowCloseButton( false )
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
				datastream.StreamToServer( "loadPlayer", {} )
				basicload_Frame:Close()
			end	
end
concommand.Add( "pnrp_loadin",  basicLoadWindow )
--concommand.Add( "pnrp_loadin",  GM.loadin_window )
