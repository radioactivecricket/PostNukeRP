local chatsounds = {}

chatsounds["omg"] = "vo/NovaProspekt/al_ohmygod.wav"


function PNRP.ChatSounds( ply, text )

	for k, v in pairs( chatsounds ) do
	
		if string.find( string.lower( text ), k ) then
		
			ply:EmitSound( v )
			
		end
		
	end
	
	local chat = string.Explode( " ", string.lower( text ) )
	local chatArray = {  }
	
 	for i,v in ipairs(chat) do table.insert(chatArray,v) end
	table.remove(chatArray,1)
	
	for cmd, func in pairs( PNRP.ChatCommands ) do
		--Runs Console Commands
		
		if chat[1] == "/run" then
		
			local sayString
			if chatArray != nil then
				sayString = " "
				
				for i,v in ipairs(chatArray) do sayString = sayString.." "..v end
				
				ply:ConCommand(sayString)
				return ""
				
			else
					
				ply:ConCommand(chat[2])
				return ""
				
			end
		elseif chat[1] == cmd then --Runs /Commands
				
			if chat[2] != "" then
				
				if chat[3] != "" then
		
					func( ply, chat[2], chat[3] )
					return ""
				
				else
					
					func( ply, chat[2] )
					return ""
				end
				
			else

				func( ply )
				return ""
				
			end	
			
		end
		
	end	
	
	for cmd, cnCmd in pairs( PNRP.ChatConCommands ) do
		
		if chat[1] == cmd then --Runs /ConCommands
			local sayString
			if chatArray != nil then
				
				sayString = cnCmd.." "
				for i,v in ipairs(chatArray) do sayString = sayString.." "..v end

				ply:ConCommand(sayString)
				return ""
				
			else
		
				ply:ConCommand( cnCmd )
				return ""
		
			end	
	
		end
	
	end
	
end
	
hook.Add("PlayerSay", "PNRPChatSounds", PNRP.ChatSounds)


function GM:PlayerCanHearPlayersVoice( pListener, pTalker )
	local curDistance = pListener:GetShootPos():Distance(pTalker:GetShootPos())
	local maxDistance = GetConVarNumber("pnrp_voiceDist")
	
	if GetConVarNumber("pnrp_voiceLimit") == 1 then
		if curDistance < maxDistance then
			return true
		else
			return false
		end
	end
	return true
end

function GM:PlayerCanSeePlayersChat( strText, bTeamOnly, pListener, pTalker )
	local curDistance = pListener:GetShootPos():Distance(pTalker:GetShootPos())
	local maxDistance = GetConVarNumber("pnrp_voiceDist")
	
	if GetConVarNumber("pnrp_voiceLimit") == 1 then
		if curDistance < maxDistance then
			return true
		else
			return false
		end
	end
	return true
end

--EOF