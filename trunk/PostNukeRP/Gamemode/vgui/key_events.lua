
KeyEvents = {}
--Key Referance http://wiki.garrysmod.com/?title=IN_KEYS

local function KeyThink( )
	
	for i=1, 130 do
		if( input.IsKeyDown(i)) then
			
			if(KeyEvents[i]==0 or KeyEvents[i]==nil) then KeyEvents[i] = 1
			elseif(KeyEvents[i]==1) then KeyEvents[i] = 2
			elseif(KeyEvents[i]==2) then KeyEvents[i] = 2
			elseif(KeyEvents[i]==3) then KeyEvents[i] = 1 end
			
		else
			if(KeyEvents[i]==0  or KeyEvents[i]==nil) then KeyEvents[i] = 0
			elseif(KeyEvents[i]==1) then KeyEvents[i] = 3
			elseif(KeyEvents[i]==2) then KeyEvents[i] = 3
			elseif(KeyEvents[i]==3) then KeyEvents[i] = 0 end
		end
		
		if(KeyEvents[i]==1) then 
			if i == KEY_F6 then LocalPlayer():ChatPrint("You pressed key F6") 
			elseif i == KEY_F7 then -- Enter Code Here
			elseif i == KEY_F8 then -- Enter Code Here 
			elseif i == KEY_F9 then -- Enter Code Here 
			elseif i == KEY_F10 then -- Enter Code Here
			elseif i == KEY_F11 then -- Enter Code Here
			elseif i == KEY_F12 then -- Enter Code Here
			end
		end
--		elseif(KeyEvents[i]==3) then LocalPlayer():ChatPrint("You released key " .. i) end
		
	end
end
hook.Add( "Think", "CheckKeyInput", KeyThink );


--EOF