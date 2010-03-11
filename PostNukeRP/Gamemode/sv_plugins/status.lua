
----------------------------------------------------
---		This file includes health regen and
---		endurance drain and regen outside of items.
---		Also controls the sleep systems (of course).
----------------------------------------------------

function StatCheck()
	for k, v in pairs(player.GetAll()) do
		local UpdateTime = 0
		if v:GetNetworkedBool("IsAsleep") then
			UpdateTime = 5
		else
			UpdateTime = 60
		end
		
		--Health checks
		if v:Alive() and CurTime() - v:GetTable().LastHealthUpdate > UpdateTime and not v:IsOutside() then
			local health = v:Health()
			
			if not ( health == v:GetMaxHealth() ) then
				
				v:SetHealth( health + 1 )
				if ( v:GetMaxHealth() < health + 1  ) then
					v:SetHealth( v:GetMaxHealth() )
				end
			end
			v:GetTable().LastHealthUpdate = CurTime()
		end
		
		
		local runModifier = 0
		
		if v:KeyDown(IN_FORWARD) or v:KeyDown(IN_LEFT) or v:KeyDown(IN_RIGHT) or v:KeyDown(IN_BACK) then
			runModifier = runModifier + 1
			if v:KeyDown(IN_SPEED) then
				runModifier = runModifier + 3
			end
		end
		
		local EndUpdateTime 
		if v:Team() == TEAM_WASTELANDER then
			EndUpdateTime = UpdateTime / (3 + runModifier)
			if v:GetNetworkedBool("IsAsleep") then
				EndUpdateTime = UpdateTime / 5 
			end
		else
			EndUpdateTime = UpdateTime / (5 + runModifier)
			if v:GetNetworkedBool("IsAsleep") then
				EndUpdateTime = UpdateTime / 5 
			end
		end
		--Endurance checks
		if v:Alive() and CurTime() - v:GetTable().LastEndUpdate > EndUpdateTime then
			local endur = v:GetNetworkedInt("Endurance")
			
			if v:GetNetworkedBool("IsAsleep") then
				v:SetNetworkedInt("Endurance", endur + 1)
			else
				v:SetNetworkedInt("Endurance", endur - 1)
			end
			
			if v:GetNetworkedInt("Endurance") <= 0 then
				v:ChatPrint("You've fallen unconcious due to fatigue!")
				EnterSleep(v)
			elseif v:GetNetworkedInt("Endurance") >= 100 then
				if v:GetNetworkedBool("IsAsleep") then
					ExitSleep(v)
				end
				v:SetNetworkedInt("Endurance", 100)
			end
			v:GetTable().LastEndUpdate = CurTime()
		end
	end
end
hook.Add("Think", "StatCheck", StatCheck)

-----------------------------
---	Exit/Enter Sleep
-----------------------------
function EnterSleep ( ply )
	local IsSleeping = ply:GetNetworkedBool("IsAsleep")
	local curEndurance = ply:GetNetworkedInt("Endurance")
	
	if IsSleeping == false and curEndurance < 100 then
		if not ply:GetTable().SleepSound then
			ply:GetTable().SleepSound = CreateSound(ply, "npc/ichthyosaur/water_breath.wav")
		end
		ply:SetNetworkedBool("IsAsleep", true)
		ply:GetTable().SleepSound:PlayEx(0.10, 100)
		
		ply:Freeze(true)
		
		local rfilter = RecipientFilter()
		rfilter:RemoveAllPlayers()
		rfilter:AddPlayer( ply )
		
		umsg.Start("sleepeffects", rfilter)
			umsg.Bool(true)
		umsg.End()
	end
end

function EnterSleepCmd( ply )
	if not ply:IsOutside() then
		if ply:GetNetworkedInt("Endurance") < 80 then
			EnterSleep( ply )
		else
			ply:ChatPrint("You aren't tired enough to sleep!")
		end
	else
		ply:ChatPrint("You must be inside to sleep!")
	end
end
concommand.Add( "pnrp_sleep", EnterSleepCmd )
PNRP.ChatConCmd( "/sleep", "pnrp_sleep" )

function ExitSleep( ply )
	local IsSleeping = ply:GetNetworkedBool("IsAsleep")
	local curEndurance = ply:GetNetworkedInt("Endurance")
	--ply:GetTable().SleepSound
	if IsSleeping == true then
		ply:SetNetworkedBool("IsAsleep", false)
		if ply:GetTable().SleepSound then
			ply:GetTable().SleepSound:Stop()
		end
		
		ply:Freeze(false)
		
		local rfilter = RecipientFilter()
		rfilter:RemoveAllPlayers()
		rfilter:AddPlayer( ply )
		
		umsg.Start("sleepeffects", rfilter)
			umsg.Bool(false)
		umsg.End()
	end
end

function ExitSleepCmd( ply )
	if ply:GetNetworkedBool("IsAsleep") then
		ExitSleep( ply )
	else
		ply:ChatPrint("You're not asleep!")
	end
end
concommand.Add( "pnrp_wake", ExitSleepCmd )
PNRP.ChatConCmd( "/wake", "pnrp_wake" )
