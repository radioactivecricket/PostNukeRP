PNRP_HUD = { }

local colors =
{
 
	background =
	{
 
		border = Color( 190, 255, 128, 255 ),
		background = Color( 51, 58, 51, 100 )
 
	},
 
	text =
	{
 
		shadow = Color( 0, 0, 0, 200 ),
		text = Color( 255, 255, 255, 255 )
 
	},
 
	health_bar =
	{
 
		border = Color( 255, 0, 0, 255 ),
		background = Color( 255, 0, 0, 75 ),
		shade = Color( 255, 104, 104, 255 ),
		fill = Color( 232, 0, 0, 255 )
 
	},
 
	suit_bar =
	{
 
		border = Color( 0, 0, 255, 255 ),
		background = Color( 0, 0, 255, 75 ),
		shade = Color( 136, 136, 255, 255 ),
		fill = Color( 0, 0, 219, 255 )
 
	},
	inside_indic =
	{
	 
		offhighlight = Color( 200, 155, 200, 125 ),
		offfill = Color( 255, 0, 0, 255 ),
		onhighlight = Color( 200, 255, 200, 125 ),
		onfill = Color( 0, 175, 0, 255 )
	 
	}
	
 
}

local vars =
{
 
	font = "TargetID",
 
	padding = 10,
	margin = 35,
 
	text_spacing = 2,
	bar_spacing = 5,
 
	bar_height = 16,
 
	width = 0.25
 
};

function hidehud(name)
	for k, v in pairs{"CHudHealth", "CHudBattery"} do
		if name == v then return false end
	end
end
hook.Add("HUDShouldDraw", "hidehud", hidehud)

CreateConVar("pnrp_DeathNotice","1",FCVAR_NOTIFY + FCVAR_ARCHIVE)
function GM:DrawDeathNotice(x, y)
	local deathnotice = GetConVarNumber("pnrp_DeathNotice")
	local th = PNRP_HUD:TextSize( "TEXT", vars.font )
	local height = vars.bar_height + ( vars.padding * 4 ) + th
	y = height / ScrH()
	if deathnotice == 1 then 
		self.BaseClass:DrawDeathNotice(x, y)
	else
		return
	end
end

local function HUDPaint( )
	
	client = client or LocalPlayer( )				-- set a shortcut to the client
	if( !client:Alive( ) ) then return end				-- don't draw if the client is dead
 	local person = LocalPlayer()
 	
	local _, th = PNRP_HUD:TextSize( "TEXT", vars.font )		-- get text size( height in this case )
 
	local i = 3				-- shortcut to how many items( bars + text ) we have
 
	local width = ( ScrW() - vars.padding * 2 )
	local bar_width = (width / i ) - vars.bar_spacing - vars.padding
	local height = vars.bar_height + ( vars.padding * 2 ) + th
	
 	local x = 2
 	local y = 25
 	
	local cx = x + vars.padding					-- get x and y of contents
	local cy = y + vars.padding
 
	PNRP_HUD:PaintRoundedPanel( 6, x, y, width, height, colors.background )	-- paint the background panel
 	
	--Draws the Health Bar
	local by = vars.padding;
 	local MaxHealth = LocalPlayer():GetNetworkedInt( "MaxHealth" )
 	
	local text = string.format( "Health: %iHP", client:Health( ) )	-- get health text
 	PNRP_HUD:PaintText( cx, cy, text, vars.font, colors.text )	-- paint health text and health bar
	PNRP_HUD:PaintBar( cx, cy + th + vars.text_spacing, bar_width, vars.bar_height, colors.health_bar, client:Health( ) / MaxHealth )
	
	--Draws Suite Armor Bar
 	by = by +bar_width + vars.bar_spacing
 	
	local text = string.format( "Suit: %iSP", client:Armor( ) )	-- get suit text
	PNRP_HUD:PaintText( cx + by, cy, text, vars.font, colors.text )	-- paint suit text and suit bar
	PNRP_HUD:PaintBar( cx + by, cy + th + vars.text_spacing, bar_width, vars.bar_height, colors.suit_bar, client:Armor( ) / 100 )
	
	--Draws the Endurance Bar
	by = by + bar_width + vars.bar_spacing + vars.bar_spacing
	
	local endur = person:GetNetworkedInt("Endurance")
 	local endPerc = endur / 100
 	
 	end_bar =
	{
 
		border = Color( 0, 255, 0, 255 ),
		background = Color( 0, 255, 0, 75 ),
		shade = Color( 136, 255, 136, 255 ),
		fill = Color(0, 255, 30, 155)
 
	}
 	
	local text = string.format( "Endurance: %i", endur )
 	
 	PNRP_HUD:PaintText( cx + by, cy, text, vars.font, colors.text )	
 	PNRP_HUD:PaintBar( cx + by, cy + th + vars.text_spacing, bar_width, vars.bar_height, end_bar, endPerc )
 	--Draws the sleep indication line
 	draw.RoundedBox(0, cx + bar_width * 0.8 + by, cy + th + vars.text_spacing, 1, vars.bar_height, Color(255, 255, 255, 150))
 	
 	--Draws Location Indicator
 	local indW = 10
 	local indH = 10
 	
 	PNRP_HUD:PaintRoundedPanel( 6, x, y + height, indW + (vars.padding * 2) + 60, indH + (vars.padding * 2), colors.background )
 	PNRP_HUD:PaintInsideIndic(x + vars.padding, y + height + vars.padding, indW, indH, vars.font, colors.inside_indic )
 	
end
hook.Add( "HUDPaint", "PaintHud", HUDPaint )

function PNRP_HUD:PaintInsideIndic(x, y, w, h, font, color )
	
	surface.SetFont( font )
	surface.SetTextPos( x+w+5, y-6 )
	
	if (LocalPlayer():IsOutside()) then
	
		surface.SetDrawColor( color.offfill ) 
		surface.DrawRect(x, y, w, h )
		
		surface.SetDrawColor( color.offhighlight ) 
		surface.DrawRect(x+1, y+1, w/2, h/2 )
		surface.DrawText( "Outside" )
	
	else 
	
		surface.SetDrawColor( color.onfill ) 
		surface.DrawRect(x, y, w, h )
		
		surface.SetDrawColor( color.onhighlight ) 
		surface.DrawRect(x+1, y+1, w/2, h/2 )
		surface.DrawText( "Inside" )
	end

end

function PNRP_HUD:PaintBar( x, y, w, h, color, value )
 
	self:PaintPanel( x, y, w, h, color );
 
	x = x + 1; y = y + 1;
	w = w - 2; h = h - 2;
 
	local width = w * math.Clamp( value, 0, 1 );
	local shade = 4;
 
	surface.SetDrawColor( color.shade );
	surface.DrawRect( x, y, width, shade );
 
	surface.SetDrawColor( color.fill );
	surface.DrawRect( x, y + shade, width, h - shade );
 
end
 
function PNRP_HUD:PaintPanel( x, y, w, h, color )
 
	surface.SetDrawColor( color.border );
	surface.DrawOutlinedRect( x, y, w, h );
 
	x = x + 1; y = y + 1;
	w = w - 2; h = h - 2;
 
	surface.SetDrawColor( color.background );
	surface.DrawRect( x, y, w, h );
 
end

function PNRP_HUD:PaintRoundedPanel(r, x, y, w, h, color )
  
	x = x + 1; y = y + 1;
	w = w - 2; h = h - 2;
 
	draw.RoundedBox(r, x, y, w, h, color.background)
 
end
 
function PNRP_HUD:PaintText( x, y, text, font, color )
 
	surface.SetFont( font );
 
	surface.SetTextPos( x + 1, y + 1 );
	surface.SetTextColor( color.shadow );
	surface.DrawText( text );
 
	surface.SetTextPos( x, y );
	surface.SetTextColor( color.text  );
	surface.DrawText( text );
 
end

function PNRP_HUD:TextSize( text, font )
 
	surface.SetFont( font );
	return surface.GetTextSize( text );
 
end


--EOF