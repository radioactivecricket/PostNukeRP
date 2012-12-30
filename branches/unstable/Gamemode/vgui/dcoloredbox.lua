/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DColouredBox
	
*/

local PANEL = {}

AccessorFunc( PANEL, "m_bBorder", 				"Border" )
AccessorFunc( PANEL, "m_Color", 				"Color" )

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self:SetBorder( true )
	self:SetColor( Color( 0, 255, 0, 255 ) )

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()

	surface.SetDrawColor( self.m_Color.r, self.m_Color.g, self.m_Color.b, 255 )
	self:DrawFilledRect()

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:PaintOver()

	if ( !self.m_bBorder ) then return end
	
	surface.SetDrawColor( 0, 0, 0, 255 )
	self:DrawOutlinedRect()

end

vgui.Register( "DColouredBox", PANEL, "DPanel" )