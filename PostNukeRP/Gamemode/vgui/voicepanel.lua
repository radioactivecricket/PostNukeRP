
local PANEL = {}

Derma_Hook( PANEL, 	"Paint", 				"Paint", 	"NewVoiceNotify" )
Derma_Hook( PANEL, 	"ApplySchemeSettings", 	"Scheme", 	"NewVoiceNotify" )
Derma_Hook( PANEL, 	"PerformLayout", 		"Layout", 	"NewVoiceNotify" )

function PANEL:Init()
--	self.Avatar = vgui.Create( "AvatarImage", self )

	self.PlayerPanel = vgui.Create("DPanel", self)
--	self.PlayerPanel:SetDrawBackground( false )
	self.PlayerPanel:SetSize( 110, 90 )
	self.PlayerPanel.Paint = function()
		draw.RoundedBox( 6, 0, 0, self.PlayerPanel:GetWide(), self.PlayerPanel:GetTall(), Color( 0, 0, 0, 80 ) )		
	end

--	self.PlayerPanel.screenBG = vgui.Create("DImage", self.PlayerPanel)
--	self.PlayerPanel.screenBG:SetImage( "VGUI/gfx/pnrp_screen_1.png" )
--	self.PlayerPanel.screenBG:SetSize(self.PlayerPanel:GetWide(), self.PlayerPanel:GetTall())	
	
	self.PlayerPanel.Icon = vgui.Create("SpawnIcon", self.PlayerPanel)
	self.PlayerPanel.Icon:SetPos(25,6)
	
	self.PlayerPanel.LabelName = vgui.Create( "DLabel", self.PlayerPanel )
	self.PlayerPanel.LabelName:SetPos(10,66)
	self.PlayerPanel.LabelName:SetWide( self.PlayerPanel:GetWide() )

	self.Color = color_transparent

end

function PANEL:Setup( ply )
--	self.Avatar:SetPlayer( ply )
	
	self.Color = team.GetColor( ply:Team() )
	
	self.PlayerPanel.Icon:SetModel(ply:GetModel())

	self.PlayerPanel.LabelName:SetText( ply:Nick() )
	self.PlayerPanel.LabelName:SetColor(team.GetColor( ply:Team() ))
	
	self:InvalidateLayout()

end

derma.DefineControl( "NewVoiceNotify", "", PANEL, "DPanel" )

local pn_VoicePanelList
local pn_PlayerVoicePanels = {}

local function PlayerStartVoice( ply )
	if (!IsValid( pn_VoicePanelList ) ) then return end
	
	if ( !IsValid( ply ) ) then return end

	local pnl = vgui.Create( "NewVoiceNotify" )
	pnl:Setup( ply )
	pnl:SetSize( 115, 100 )
	pn_VoicePanelList:AddItem( pnl )
	
	pn_PlayerVoicePanels[ ply ] = pnl
end
hook.Add( "PlayerStartVoice", "PlayerStartedTheirVoice", PlayerStartVoice)

local function VoiceClean()

	for k, v in pairs( pn_PlayerVoicePanels ) do
	
		if ( !IsValid( k ) ) then
		--	GAMEMODE:PlayerEndVoice( k )
			pn_VoicePanelList:RemoveItem( pn_PlayerVoicePanels[ k ] )
			pn_PlayerVoicePanels[ k ]:Remove()
			pn_PlayerVoicePanels[ k ] = nil
		end
	
	end

end

timer.Create( "VoiceClean", 10, 0, VoiceClean )

local function PlayerEndVoice( ply )
	if ( IsValid( pn_PlayerVoicePanels[ ply ] ) ) then
		pn_VoicePanelList:RemoveItem( pn_PlayerVoicePanels[ ply ] )
		pn_PlayerVoicePanels[ ply ]:Remove()
		pn_PlayerVoicePanels[ ply ] = nil
	end
end
hook.Add( "PlayerEndVoice", "PlayerEndedTheirVoice", PlayerEndVoice)

local function VoiceVGUIOveride( ply )
	pn_VoicePanelList = vgui.Create( "DPanelList" )

	pn_VoicePanelList:ParentToHUD()
	
	pn_VoicePanelList:SetPos( ScrW() - 250, 100 )
	pn_VoicePanelList:SetSize( 200, ScrH() - 200 )
	
	pn_VoicePanelList:SetDrawBackground( false )
	pn_VoicePanelList:SetSpacing( 2 )
	pn_VoicePanelList:SetPadding( 2 )
--	pn_VoicePanelList:SetBottomUp( true )
end
hook.Add( "InitPostEntity", "CreateVoiceVGUI", VoiceVGUIOveride )
