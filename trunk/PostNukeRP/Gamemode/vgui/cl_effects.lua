-----------------------------------------------------
---		This file controls client side effects for
---		certain functions.
-----------------------------------------------------

function SleepEffects( )
	local toggle = tobool(net:ReadBit())
	
	if toggle then
		hook.Add("RenderScreenspaceEffects", "sleepingcolors", function()
				local settings = {}
				settings[ "$pp_colour_addr" ] = 0
				settings[ "$pp_colour_addg" ] = 0 
				settings[ "$pp_colour_addb" ] = 0 
				settings[ "$pp_colour_brightness" ] = -1
				settings[ "$pp_colour_contrast" ] = 0
				settings[ "$pp_colour_colour" ] =0
				settings[ "$pp_colour_mulr" ] = 0
				settings[ "$pp_colour_mulg" ] = 0
				settings[ "$pp_colour_mulb" ] = 0
				DrawColorModify(settings)
			end)
	elseif not toggle then
		hook.Remove("RenderScreenspaceEffects", "sleepingcolors")
	end
end
net.Receive("sleepeffects", SleepEffects)


-----------------------------------------------------
---					EVENT EFFECTS
---		Added with event system, for client side
---		effects.
-----------------------------------------------------

function RadStormEffects( )
	local toggle = tobool(net:ReadBit())
	
	if toggle then
		local windSound = Sound("ambient/levels/canals/windmill_wind_loop1.wav")
		LocalPlayer().WindSound = CreateSound(LocalPlayer(), windSound)
		
		LocalPlayer().WindSound:Play()
		hook.Add("Think", "radstormsound", function ()
				if LocalPlayer():IsOutside() then
					LocalPlayer().WindSound:ChangeVolume( 1, 0 )
				else
					LocalPlayer().WindSound:ChangeVolume( 0.1, 0 )
				end
			end)
		
		hook.Add("RenderScreenspaceEffects", "radstormeffects", function()
				if LocalPlayer():IsOutside() then
					local settings =
					{
						[ "$pp_colour_addr" ]		= 0.01,
						[ "$pp_colour_addg" ]		= 0.02,
						[ "$pp_colour_addb" ]		= 0,
						[ "$pp_colour_brightness" ]	= 0,
						[ "$pp_colour_contrast" ]	= 1,
						[ "$pp_colour_colour" ]		= 3,
						[ "$pp_colour_mulr" ]		= 0,
						[ "$pp_colour_mulg" ]		= 0.02,
						[ "$pp_colour_mulb" ]		= 0
					}
					DrawColorModify( settings )
					DrawMotionBlur( 0.4, 0.8, 0.01 )
					DrawBloom( 0.65, 2, 9, 9, 6, 1, 1, 1, 1 )
					DrawSobel( 0.2 )
				end
			end)
	elseif not toggle then
		if LocalPlayer().WindSound then
			LocalPlayer().WindSound:Stop()
		end
		hook.Remove("RenderScreenspaceEffects", "radstormeffects")
		hook.Remove("Think", "radstormsound")
	end
end
net.Receive("radstormeffects", RadStormEffects)
