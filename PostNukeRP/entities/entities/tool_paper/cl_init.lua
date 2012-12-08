include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

function PaperHUDLabel()
	local myPlayer = LocalPlayer()
	
	local tracedata = {}
	tracedata.start = myPlayer:GetShootPos()
	tracedata.endpos = tracedata.start + (myPlayer:GetAimVector() * 1000)
	tracedata.filter = myPlayer
	local trace = util.TraceLine(tracedata)
	
	if !trace.Entity:IsValid() then return end
	
	if trace.Entity:GetClass() == "tool_paper" then
		local font = "CenterPrintText"
		local text = trace.Entity:GetNWString("name")
		surface.SetFont(font)
		local tWidth, tHeight = surface.GetTextSize(text)
		
		draw.WordBox( 8, (ScrW() / 2) - (8 + (tWidth / 2)), (ScrH() / 2) - (16 + tHeight), text, font, Color(50,50,75,100), Color(255,255,255,255) )
	end
end
hook.Add( "HUDPaint", "PaperHUDLabel", PaperHUDLabel )

function EditPaper()
	local ply = LocalPlayer()
	local paperENT = net.ReadEntity()
	local name = net.ReadString()
	local text = net.ReadString()
	
	local w = 710
	local h = 720
	local title = "Paper Edit Window"
	
	local paper_frame = vgui.Create( "DFrame" )
		paper_frame:SetSize( w, h ) 
		paper_frame:SetPos( ScrW() / 2 - paper_frame:GetWide() / 2, ScrH() / 2 - paper_frame:GetTall() / 2 )
		paper_frame:SetTitle( "" )
		paper_frame:SetVisible( true )
		paper_frame:SetDraggable( false )
		paper_frame:ShowCloseButton( true )
		paper_frame:MakePopup()
		paper_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", paper_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_1b.png" )
			screenBG:SetKeepAspect()
			screenBG:SizeToContents()
			screenBG:SetSize(paper_frame:GetWide(), paper_frame:GetTall())
			
		local ToolName = vgui.Create( "DLabel", paper_frame )
			ToolName:SetPos(60,40)
			ToolName:SetColor(Color( 0, 255, 0, 255 ))
			ToolName:SetText( title )
			ToolName:SizeToContents()
		local setNameTxt = vgui.Create("DTextEntry", paper_frame)
			setNameTxt:SetText(name)
			setNameTxt:SetPos(60,60)
			setNameTxt:SetWide(paper_frame:GetWide()-120)
		local setTxt = vgui.Create("DTextEntry", paper_frame)
			setTxt:SetMultiline(true)
			setTxt:SetText(text)
			setTxt:SetPos(60,90)
			setTxt:SetSize(paper_frame:GetWide()-120,paper_frame:GetTall()-150)	
		
		local renameBtn = vgui.Create( "DButton", paper_frame )
			renameBtn:SetSize( 150, 15 )
			renameBtn:SetPos( paper_frame:GetWide()-360, 40 )
			renameBtn:SetText( "Read Paper" )
			renameBtn.DoClick = function( )
				local name = setNameTxt:GetValue()
				net.Start("View_Paper")
					net.WriteEntity(ply)
					net.WriteEntity(paperENT)
				net.SendToServer()
				paper_frame:Close()
			end
			
		local renameBtn = vgui.Create( "DButton", paper_frame )
			renameBtn:SetSize( 150, 15 )
			renameBtn:SetPos( paper_frame:GetWide()-210, 40 )
			renameBtn:SetText( "Save Changes" )
			renameBtn.DoClick = function( )
				local name = setNameTxt:GetValue()
				net.Start("Write_Paper")
					net.WriteEntity(ply)
					net.WriteEntity(paperENT)
					net.WriteString(setNameTxt:GetValue())
					net.WriteString(setTxt:GetValue())
				net.SendToServer()
				paper_frame:Close()
			end
end
net.Receive("Edit_Paper", EditPaper)

function ReadPaper()
	local ply = LocalPlayer()
	local paperENT = net.ReadEntity()
	local name = net.ReadString()
	local text = net.ReadString()
	
	local w = 710
	local h = 720
	local title = "Storage Selection Menu"
	
	local paper_frame = vgui.Create( "DFrame" )
		paper_frame:SetSize( w, h ) 
		paper_frame:SetPos( ScrW() / 2 - paper_frame:GetWide() / 2, ScrH() / 2 - paper_frame:GetTall() / 2 )
		paper_frame:SetTitle( "" )
		paper_frame:SetVisible( true )
		paper_frame:SetDraggable( false )
		paper_frame:ShowCloseButton( true )
		paper_frame:MakePopup()
		paper_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", paper_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_1b.png" )
			screenBG:SetKeepAspect()
			screenBG:SizeToContents()
			screenBG:SetSize(paper_frame:GetWide(), paper_frame:GetTall())
			
		local ToolName = vgui.Create( "DLabel", paper_frame )
			ToolName:SetPos(60,40)
			ToolName:SetColor(Color( 0, 255, 0, 255 ))
			ToolName:SetText( name )
			ToolName:SetFont("Trebuchet24")
			ToolName:SizeToContents()
			
		local setTxt = vgui.Create("DLabel", paper_frame)
			setTxt:SetMultiline(true)
			setTxt:SetColor(Color(0,255,0,255))
			setTxt:SetText(text)
			setTxt:SetPos(60,70)
			setTxt:SetWrap(true)
			setTxt:SetAutoStretchVertical( true )
			setTxt:SetWide(paper_frame:GetWide()-120)	
end
net.Receive("Read_Paper", ReadPaper)
