local malechatsounds = {}
local femalechatsounds = {}

	    
femalechatsounds["omfg"] = "vo/NovaProspekt/al_ohmygod.wav"
femalechatsounds["omg"] = "vo/npc/female01/goodgod.wav"
femalechatsounds["hacks"] = "vo/npc/female01/hacks01.wav"
femalechatsounds["hax"] = "vo/npc/female01/hacks02.wav"
femalechatsounds["incoming"] = "vo/canals/female01/stn6_incoming.wav"
femalechatsounds["get out"] = "vo/npc/female01/gethellout.wav"
femalechatsounds["get down"] = "vo/npc/female01/getdown02.wav"
femalechatsounds["excuse me"] = "vo/npc/female01/excuseme01.wav"
femalechatsounds["fantastic"] = "vo/npc/female01/fantastic01.wav"
femalechatsounds["im busy"] = "vo/npc/female01/busy02.wav"
femalechatsounds["behind you"] = "vo/npc/female01/behindyou01.wav"

malechatsounds["omfg"] = "vo/NovaProspekt/al_ohmygod.wav"
malechatsounds["omg"] = "vo/npc/male01/goodgod.wav"
malechatsounds["hacks"] = "vo/npc/male01/hacks01.wav"
malechatsounds["hax"] = "vo/npc/male01/hacks02.wav"
malechatsounds["incoming"] = "vo/canals/male01/stn6_incoming.wav"
malechatsounds["get out"] = "vo/npc/male01/gethellout.wav"
malechatsounds["get down"] = "vo/npc/male01/getdown02.wav"
malechatsounds["excuse me"] = "vo/npc/male01/excuseme01.wav"
malechatsounds["fantastic"] = "vo/npc/male01/fantastic01.wav"
malechatsounds["im busy"] = "vo/npc/male01/busy02.wav"
malechatsounds["behind you"] = "vo/npc/male01/behindyou01.wav"


function PNRP.ChatSounds( ply, text )
	
	if string.find(string.lower(ply:GetModel()), "/female") or
		string.find(string.lower(ply:GetModel()), "mossman") or
	    string.find(string.lower(ply:GetModel()), "alyx") then
	
		for k, v in pairs( femalechatsounds ) do
		
			if string.find( string.lower( text ), k ) then
			
				ply:EmitSound( v )
				
			end
			
		end
	else
	
		for k, v in pairs( malechatsounds ) do
		
			if string.find( string.lower( text ), k ) then
			
				ply:EmitSound( v )
				
			end
			
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