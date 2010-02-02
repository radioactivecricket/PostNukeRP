

function KeyPressed (P, key)
	--Msg (P:GetName().." pressed "..key.."\n")
	if key == KEY_F2 then
		RunConsoleCommand( "pnrp_buy_shop" )
	end
end
 
hook.Add( "KeyPress", "KeyPressedHook", KeyPressed )

--EOF