local skills_Frame
local sFrame = false

function GM.skills_window( ply )
	if sFrame then return end 
	
	skills_Frame = vgui.Create( "DFrame" )
		skills_Frame:SetSize( 400, 450 ) 
		skills_Frame:SetPos(ScrW() / 2 - skills_Frame:GetWide() / 2, ScrH() / 2 - skills_Frame:GetTall() / 2)
		skills_Frame:SetTitle( " " )
		skills_Frame:SetVisible( true )
		skills_Frame:SetDraggable( false )
		skills_Frame:ShowCloseButton( false )
		skills_Frame:MakePopup()
		skills_Frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
	
	local skillLabel_frame = vgui.Create( "DFrame" )
		skillLabel_frame:SetParent( skills_Frame )
		skillLabel_frame:SetSize( 250, 40 ) 
		skillLabel_frame:SetPos(ScrW() / 2 - skills_Frame:GetWide() / 2, ScrH() / 2 - skills_Frame:GetTall() / 2 - 15)
		skillLabel_frame:SetTitle( " " )
		skillLabel_frame:SetVisible( true )
		skillLabel_frame:SetDraggable( false )
		skillLabel_frame:ShowCloseButton( false )
		skillLabel_frame:MakePopup()
		skillLabel_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local SkillsLabel = vgui.Create("DLabel", skillLabel_frame)
			SkillsLabel:SetPos(10,0)
			SkillsLabel:SetColor( Color( 255, 255, 255, 255 ) )
			SkillsLabel:SetText( "Skills Window" )
			SkillsLabel:SetFont("Trebuchet24")
			SkillsLabel:SizeToContents()
		--Inner Frame
		local Skills_DPanel = vgui.Create( "DPanel" )
			Skills_DPanel:SetParent( skills_Frame )
			Skills_DPanel:SetPos( 5, 25 )
			Skills_DPanel:SetSize( skills_Frame:GetWide() - 15, skills_Frame:GetTall() - 55 )
			Skills_DPanel.Paint = function() -- Paint function
				surface.SetDrawColor( 50, 50, 50, 255 ) 
				surface.DrawRect( 0, 0, Skills_DPanel:GetWide(), Skills_DPanel:GetTall() ) 
			end
			
			Skills_DPanel.Icon = vgui.Create("SpawnIcon", Skills_DPanel)
			Skills_DPanel.Icon:SetModel(ply:GetModel())
			Skills_DPanel.Icon:SetPos(10, 10)
			Skills_DPanel.Icon:SetToolTip( nil )
			
			Skills_DPanel.Nick = vgui.Create("DLabel", Skills_DPanel)
			Skills_DPanel.Nick:SetPos(90, 10)
			Skills_DPanel.Nick:SetText(ply:Nick())
			Skills_DPanel.Nick:SetColor( Color( 255, 255, 255, 255 ) )
			Skills_DPanel.Nick:SizeToContents() 
			Skills_DPanel.Nick:SetContentAlignment( 5 )
			
			Skills_DPanel.Team = vgui.Create("DLabel", Skills_DPanel)
			Skills_DPanel.Team:SetPos(90, 25)
			Skills_DPanel.Team:SetText("Class: "..team.GetName(ply:Team()))
			Skills_DPanel.Team:SetColor(team.GetColor(ply:Team()))
			Skills_DPanel.Team:SizeToContents() 
			Skills_DPanel.Team:SetContentAlignment( 5 )
			
			local MemberOf
			MemberOf = ply:GetNWString("community", "N/A")
			
			Skills_DPanel.Community = vgui.Create("DLabel", Skills_DPanel)
			Skills_DPanel.Community:SetPos(90, 40)
			Skills_DPanel.Community:SetText("Member of "..MemberOf)
			Skills_DPanel.Community:SetColor( Color( 255, 255, 255, 255 ) )
			Skills_DPanel.Community:SizeToContents() 
			Skills_DPanel.Community:SetContentAlignment( 5 )
			
			Skills_DPanel.XP = vgui.Create("DLabel", Skills_DPanel)
			Skills_DPanel.XP:SetPos(90, 60)
			Skills_DPanel.XP:SetText("Current Experiance: "..GetXP())
			Skills_DPanel.XP:SetColor( Color( 255, 255, 255, 255 ) )
			Skills_DPanel.XP:SizeToContents() 
			Skills_DPanel.XP:SetContentAlignment( 5 )
			
			Skills_DPanel.Run = vgui.Create("DLabel", Skills_DPanel)
			Skills_DPanel.Run:SetPos(250, 20)
			Skills_DPanel.Run:SetText("Run Speed: "..ply:GetRunSpeed( ))
			Skills_DPanel.Run:SetColor( Color( 255, 255, 255, 255 ) )
			Skills_DPanel.Run:SizeToContents() 
			Skills_DPanel.Run:SetContentAlignment( 5 )
						
			local maxWeight
			if ply:Team() == TEAM_SCAVENGER then
				maxWeight = GetConVar("pnrp_packCapScav"):GetInt() + (GetSkill("Backpacking")*10)
			else
				maxWeight = GetConVar("pnrp_packCap"):GetInt() + (GetSkill("Backpacking")*10)
			end
			Skills_DPanel.BackPk = vgui.Create("DLabel", Skills_DPanel)
			Skills_DPanel.BackPk:SetPos(250, 35)
			Skills_DPanel.BackPk:SetText("Backpack Size: "..maxWeight)
			Skills_DPanel.BackPk:SetColor( Color( 255, 255, 255, 255 ) )
			Skills_DPanel.BackPk:SizeToContents() 
			Skills_DPanel.BackPk:SetContentAlignment( 5 )
		
		--Skills Section
		Skills_DPanel.SKBLabel = vgui.Create("DLabel", Skills_DPanel)
		Skills_DPanel.SKBLabel:SetPos(10, 80)
		Skills_DPanel.SKBLabel:SetText("Base Skills:")
		Skills_DPanel.SKBLabel:SetColor( Color( 255, 255, 255, 255 ) )
		Skills_DPanel.SKBLabel:SizeToContents() 
		Skills_DPanel.SKBLabel:SetContentAlignment( 5 )
		
		local btnXLoc = Skills_DPanel:GetWide() - 115
		Skills_DPanel.Athletics = vgui.Create("DLabel", Skills_DPanel)
		Skills_DPanel.Athletics:SetPos(10, 102)
		Skills_DPanel.Athletics:SetText("Athletics (Max Level "..PNRP.Skills["Athletics"].maxlvl..")")
		Skills_DPanel.Athletics:SetColor( Color( 255, 255, 255, 255 ) )
		Skills_DPanel.Athletics:SizeToContents() 
		Skills_DPanel.Athletics:SetContentAlignment( 5 )
		UpSkillBtn("Athletics", btnXLoc, 100, Skills_DPanel)
		SKlevel_Bar("Athletics", GetSkill("Athletics"), 10, 120, Skills_DPanel)
		
		Skills_DPanel.Backpacking = vgui.Create("DLabel", Skills_DPanel)
		Skills_DPanel.Backpacking:SetPos(10, 142)
		Skills_DPanel.Backpacking:SetText("Backpacking (Max Level "..PNRP.Skills["Backpacking"].maxlvl..")")
		Skills_DPanel.Backpacking:SetColor( Color( 255, 255, 255, 255 ) )
		Skills_DPanel.Backpacking:SizeToContents() 
		Skills_DPanel.Backpacking:SetContentAlignment( 5 )
		UpSkillBtn("Backpacking", btnXLoc, 140, Skills_DPanel)
		SKlevel_Bar("Backpacking", GetSkill("Backpacking"), 10, 160, Skills_DPanel)
		
		Skills_DPanel.Salvaging = vgui.Create("DLabel", Skills_DPanel)
		Skills_DPanel.Salvaging:SetPos(10, 182)
		Skills_DPanel.Salvaging:SetText("Salvaging (Max Level "..PNRP.Skills["Salvaging"].maxlvl..")")
		Skills_DPanel.Salvaging:SetColor( Color( 255, 255, 255, 255 ) )
		Skills_DPanel.Salvaging:SizeToContents() 
		Skills_DPanel.Salvaging:SetContentAlignment( 5 )
		UpSkillBtn("Salvaging", btnXLoc, 180, Skills_DPanel)
		SKlevel_Bar("Salvaging", GetSkill("Salvaging"), 10, 200, Skills_DPanel)
		
		Skills_DPanel.Scavenging = vgui.Create("DLabel", Skills_DPanel)
		Skills_DPanel.Scavenging:SetPos(10, 222)
		Skills_DPanel.Scavenging:SetText("Scavenging (Max Level "..PNRP.Skills["Scavenging"].maxlvl..")")
		Skills_DPanel.Scavenging:SetColor( Color( 255, 255, 255, 255 ) )
		Skills_DPanel.Scavenging:SizeToContents() 
		Skills_DPanel.Scavenging:SetContentAlignment( 5 )
		UpSkillBtn("Scavenging", btnXLoc, 220, Skills_DPanel)
		SKlevel_Bar("Scavenging", GetSkill("Scavenging"), 10, 240, Skills_DPanel)
		
		Skills_DPanel.Weapon_Handling = vgui.Create("DLabel", Skills_DPanel)
		Skills_DPanel.Weapon_Handling:SetPos(10, 262)
		Skills_DPanel.Weapon_Handling:SetText("Weapon Handling (Max Level "..PNRP.Skills["Weapon Handling"].maxlvl..")")
		Skills_DPanel.Weapon_Handling:SetColor( Color( 255, 255, 255, 255 ) )
		Skills_DPanel.Weapon_Handling:SizeToContents() 
		Skills_DPanel.Weapon_Handling:SetContentAlignment( 5 )
		UpSkillBtn("Weapon Handling", btnXLoc, 260, Skills_DPanel)
		SKlevel_Bar("Weapon Handling", GetSkill("Weapon Handling"), 10, 280, Skills_DPanel)
	
	--Class Specific Skill
		Skills_DPanel.ClsSKLabel = vgui.Create("DLabel", Skills_DPanel)
		Skills_DPanel.ClsSKLabel:SetPos(10, 320)
		Skills_DPanel.ClsSKLabel:SetText("Class Skill:")
		Skills_DPanel.ClsSKLabel:SetColor( Color( 255, 255, 255, 255 ) )
		Skills_DPanel.ClsSKLabel:SizeToContents() 
		Skills_DPanel.ClsSKLabel:SetContentAlignment( 5 )
		
		local clsSPName
		for skillname, skill in pairs( PNRP.Skills ) do
			if skill.class != nil then
				for classname, class in pairs( PNRP.Skills[skill.name].class ) do
					if tostring(ply:Team()) == tostring(class) then
						clsSPName = skill.name
					end
				end
			end
		end	
		if clsSPName then
			Skills_DPanel.ClsSkill = vgui.Create("DLabel", Skills_DPanel)
			Skills_DPanel.ClsSkill:SetPos(10, 342)
			Skills_DPanel.ClsSkill:SetText(clsSPName.." (Max Level "..PNRP.Skills[clsSPName].maxlvl..")")
			Skills_DPanel.ClsSkill:SetColor( Color( 255, 255, 255, 255 ) )
			Skills_DPanel.ClsSkill:SizeToContents() 
			Skills_DPanel.ClsSkill:SetContentAlignment( 5 )
			UpSkillBtn(clsSPName, btnXLoc, 340, Skills_DPanel)
			SKlevel_Bar(clsSPName, GetSkill(clsSPName), 10, 360, Skills_DPanel)
		end
	
	--//Skills Main Menu
		local SkillMenu_frame = vgui.Create( "DFrame" )
			SkillMenu_frame:SetParent( skills_Frame )
			SkillMenu_frame:SetSize( 100, Skills_DPanel:GetTall() ) 
			SkillMenu_frame:SetPos( ScrW() / 2 + skills_Frame:GetWide() / 2 + 5, ScrH() / 2 - skills_Frame:GetTall() / 2 + 25)
			SkillMenu_frame:SetTitle( " " )
			SkillMenu_frame:SetVisible( true )
			SkillMenu_frame:SetDraggable( false )
			SkillMenu_frame:ShowCloseButton( false )
			SkillMenu_frame:MakePopup()
			SkillMenu_frame.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
			
			local sMenuList = vgui.Create( "DPanelList", SkillMenu_frame )
				sMenuList:SetPos( 0,0 )
				sMenuList:SetSize( SkillMenu_frame:GetWide(), SkillMenu_frame:GetTall() )
				sMenuList:SetSpacing( 5 )
				sMenuList:SetPadding(3)
				sMenuList:EnableHorizontal( false ) 
				sMenuList:EnableVerticalScrollbar( true ) 	
				
				local BlankLabel1 = vgui.Create("DLabel", sMenuList	)
					BlankLabel1:SetColor( Color( 255, 255, 255, 0 ) )
					BlankLabel1:SetText( " " )
					BlankLabel1:SizeToContents()
					sMenuList:AddItem( BlankLabel1 )
				local createBtn = vgui.Create("DButton") 
					createBtn:SetParent( sMenuList ) 
					createBtn:SetText( "Exit" ) 
					createBtn:SetSize( 100, 20 ) 
					createBtn.DoClick = function() skills_Frame:Close() end	
					sMenuList:AddItem( createBtn )
	
	function skills_Frame:Close()                  
		sFrame = false                  
		self:SetVisible( false )                  
		self:Remove()          
	end 
end
concommand.Add( "pnrp_skills",  GM.skills_window )

function UpSkillBtn(Skill, XLoc, YLoc, parent_frame)
	local SKUpBtn = vgui.Create("DButton") 
		SKUpBtn:SetParent( parent_frame ) 
		SKUpBtn:SetText( "Upgrade" ) 
		SKUpBtn:SetPos( XLoc, YLoc)
		SKUpBtn:SetSize( 100, 20 ) 
		SKUpBtn:SetDisabled(canUpSkillBtn(Skill, GetSkill(Skill)))
		SKUpBtn.DoClick = function() 
			RunConsoleCommand( "pnrp_upgradeskill", Skill )
			skills_Frame:Close() 
			openSkillsTimer()
		end	
end

function canUpSkillBtn(Skill, skillLvl)
	--This may seem backward, but its used to dissable the button.
	if skillLvl >= PNRP.Skills[Skill].maxlvl then 
		return true
	end
	local expCost = PNRP.Skills[Skill].basecost * (2^(skillLvl))
	if GetXP() < expCost then
		return true
	end
	return false
end

function openSkillsTimer()
	local ply = LocalPlayer()
	timer.Create(tostring(ply:UniqueID()), 0.5, 1, function()  
		RunConsoleCommand( "pnrp_skills" )
	end)
end

function SKlevel_Bar(Skill, CurLvl, XLoc, YLoc, parent_frame)

	local SkillBar = vgui.Create( "DPanel", parent_frame )
		SkillBar:SetPos( XLoc, YLoc )
		SkillBar:SetSize( parent_frame:GetWide() - 20, 20 )
		SkillBar:SetToolTip( PNRP.Skills[Skill].desc )
		SkillBar.Paint = function()
			surface.SetDrawColor( 50, 50, 50, 255 )			
		end
		local StatusBarBG = vgui.Create("DColouredBox", SkillBar)
			StatusBarBG:SetPos(0, 0)
			StatusBarBG:SetSize( SkillBar:GetWide(), SkillBar:GetTall() )
			StatusBarBG:SetColor( Color( 255, 255, 255))
		local StatusBarBG = vgui.Create("DColouredBox", SkillBar)
			StatusBarBG:SetPos(1, 1)
			StatusBarBG:SetSize( SkillBar:GetWide()-2, SkillBar:GetTall()-2 )
			StatusBarBG:SetColor( Color( 122, 197, 205))
		local StatusBar = vgui.Create("DColouredBox", SkillBar)
			StatusBar:SetPos(1, 1)
			StatusBar:SetSize( SkillBar:GetWide() * ( CurLvl / PNRP.Skills[Skill].maxlvl )-2, SkillBar:GetTall()-2 )
			StatusBarBG:SetColor( Color( 55, 128, 219))

		local lvlCost = PNRP.Skills[Skill].basecost * (2^(CurLvl))
		local StatusLabel = vgui.Create("DLabel", SkillBar)
			StatusLabel:SetPos(5, 3)
			StatusLabel:SetColor( Color( 0, 0, 0, 255 ) )
			StatusLabel:SetText("Level: "..CurLvl.."       Next Level Cost: "..lvlCost)
			StatusLabel:SizeToContents()
end