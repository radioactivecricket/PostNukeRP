

function PNRP.renderTest(ply)
	local tr = ply:TraceFromEyes(200)
	cam.Start3D(EyePos(),EyeAngles()) -- Start the 3D function so we can draw onto the screen.
		render.SetMaterial( "sprites/splodesprite" ) -- Tell render what material we want, in this case the flash from the gravgun
		render.DrawSprite(tr, 16, 16, Color(255,255,255,255)) -- Draw the sprite in the middle of the map, at 16x16 in it's original colour with full alpha.
	cam.End3D()
end 

concommand.Add( "pnrp_rendertest", PNRP.renderTest )