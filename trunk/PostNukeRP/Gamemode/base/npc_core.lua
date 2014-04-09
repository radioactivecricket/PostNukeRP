
local petDebug = 0
function togglePetDebug(ply, cmd, args)
	if ply:IsAdmin() then
		if petDebug == 0 then
			petDebug = 1
			ply:ChatPrint("Pet Debug: Enabled")
		else
			petDebug = 0
			ply:ChatPrint("Pet Debug: Disabled")
		end
	end
end
concommand.Add( "pnrp_petdebug", togglePetDebug )

function changePetActivity(ENT)
	local target = ENT:GetTarget()
	if ENT.Waiting == false then
				
		if ENT.NPCMode ~= -1 then
			if timer.Exists("hdIdleSound_"..tostring(transENT)) then
				timer.Destroy("hdIdleSound_"..tostring(transENT))
			end
		end
		
		--Stay or Wander--
		if ENT.NPCMode >= 0 and ENT:GetNPCState( ) ~= NPC_STATE_COMBAT then -- Wait and Wonder
			ENT.Option = 0
			ENT:SetNPCState(NPC_STATE_IDLE)
			local schedNum = math.random(10)
			if schedNum > 5 then
				ENT.Waiting = true
				ENT.NPCMode = 1
				timer.Simple( math.random(5), function()
					ENT.Waiting = false
				end)
				if schedNum < 8 then
					ENT:SelectSchedule( SCHED_IDLE_WANDER )
				elseif schedNum < 10 then
					ENT:SelectSchedule( SCHED_IDLE_WALK )
				else
					ENT:SelectSchedule( SCHED_PATROL_RUN )
				end
			else
				ENT.Waiting = true
				ENT.NPCMode = 0
				timer.Simple( math.random(5), function()
					ENT.Waiting = false
				end)
				ENT:SelectSchedule( SCHED_IDLE_STAND )
				ENT:IdleSounds()
			end		
		end
		
		--Start Hide--
		if ENT:GetNPCState( ) == NPC_STATE_COMBAT then --Evasive Action
			ENT.Option = 0
			ENT.Waiting = true
			ENT:FoundEnemySound( )
			local timerID = tostring(ENT).."_ECheck"
			timer.Create(timerID, math.random(5), 0, function()
				if IsValid(ENT) then
					if !IsValid(ENT:GetEnemy( )) then
						ENT.NPCMode = 0
						ENT:SelectSchedule( SCHED_IDLE_STAND )
						if timer.Exists(timerID) then timer.Destroy( timerID ) end
					end
					ENT.Waiting = false
				else
					if timer.Exists(timerID) then timer.Destroy( timerID ) end
				end
			end)
			if ENT.NPCMode == -11 then
				ENT.NPCMode = -12
				ENT:SelectSchedule( SCHED_TAKE_COVER_FROM_ENEMY )
			else
				ENT.NPCMode = -11
				ENT:SelectSchedule( SCHED_RUN_FROM_ENEMY )
			end
			ENT:HDAlertSound()
		end
		
		--Star Cower--
		if ENT:GetNPCState( ) == NPC_STATE_ALERT then
			ENT.Option = 0
			ENT.Waiting = true
			ENT.NPCMode = -13
			ENT:FoundEnemySound( )
			timer.Simple( math.random(5), function()
				if IsValid(ENT) then
					if ENT.NPCMode < -10 then	
						if IsValid(ENT:GetEnemy( )) then
							print(tostring(ENT:GetEnemy( )))
							ENT.NPCMode = 0
							ENT.Waiting = false
						end
					end
				end
			end)
			ENT:FoundEnemySound( )
			ENT:SelectSchedule( SCHED_COWER )
			ENT:HDAlertSound()
		end
		
		--Fix NPC State--
		if ENT:GetNPCState( ) == NPC_STATE_IDLE and ENT.NPCMode < -10 then
			ENT.Option = 0
			ENT.NPCMode = 0
		end
	end
	
	if petDebug == 1 then
		local petString = ENT:GetNetworkedString("name")
		if !ENT.dbTXT then ENT.dbTXT = petString end
		local state = ENT:GetNPCState( )
		if state == -1 then state = "invalid" end
		if state == 0 then state = "none" end
		if state == 1 then state = "idle" end
		if state == 2 then state = "alert" end
		if state == 3 then state = "combat" end
		if state == 4 then state = "script" end
		if state == 5 then state = "play dead" end
		if state == 6 then state = "prone" end
		if state == 7 then state = "dead" end
		local mode = ENT.NPCMode
		if mode == 0 then mode = "wait" end
		if mode == 1 then mode = "wonder" end
		if mode == -1 then mode = "stay" end
		if mode == -2 then mode = "follow" end
		if mode == -11 then mode = "run" end
		if mode == -12 then mode = "hide" end
		if mode == -13 then mode = "cower" end
		petString = ENT.dbTXT.." [Mode: "..mode.." State: "..state.." Target: "..tostring(target).."]"
		ENT:SetNetworkedString("name", petString)
	elseif ENT.dbTXT then
		ENT:SetNetworkedString("name", ENT.dbTXT)
		ENT.dbTXT = nil
	end
end 


