-----------------------------------------------------
---		This file controls client side effects for
---		certain functions.
-----------------------------------------------------

function SleepEffects( um )
	local toggle = um:ReadBool()
	
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
usermessage.Hook("sleepeffects", SleepEffects)