
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
				v:SetNetworkedInt("Endurance", endur + 2)
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
		
		
		if ply:InVehicle() then
			ply:Freeze(true)
		else
			ply:GetTable().WeaponsForSleep = {}
			ply:GetTable().ClipsForSleep = {}
			ply:GetTable().AmmoForSleep = {}
			for k,v in pairs(ply:GetWeapons( )) do
				ply:GetTable().WeaponsForSleep[k] = v:GetClass()
				ply:GetTable().ClipsForSleep[k] = v:Clip1()
			end
			
			for i = 1, 22 do
				ply:GetTable().AmmoForSleep[i] = ply:GetAmmoCount(PNRP.ConvertAmmoType(i))
			end
			
			local ragdoll = ents.Create("prop_ragdoll")
			ragdoll:SetPos(ply:GetPos())
			ragdoll:SetAngles(Angle(0,ply:GetAngles().Yaw,0))
			ragdoll:SetModel(ply:GetModel())
			ragdoll:Spawn()
			ragdoll:Activate()
			ragdoll:SetVelocity(ply:GetVelocity())
			--ragdoll.OwnerINT = player:EntIndex()
			ragdoll:GetTable().PrevPos = ply:GetPos()
			
			ply:StripWeapons()
			ply:Spectate(OBS_MODE_CHASE)
			ply:SpectateEntity(ragdoll)
			ply:GetTable().SleepRagdoll = ragdoll
			ragdoll:GetTable().OwnerID = ply:UniqueID()
			ragdoll.Owner = player
			ragdoll:SetNetworkedString("Owner", ply:Nick())
		end
		
		
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
		if not ply:Crouching() then
			if ply:GetNetworkedInt("Endurance") < 80 then
				EnterSleep( ply )
			else
				ply:ChatPrint("You aren't tired enough to sleep!")
			end
		else
			ply:ChatPrint("You cannot sleep while crouched!")
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
		if ply:InVehicle() then
			ply:Freeze(false)
		else
			local ragdoll = ply:GetTable().SleepRagdoll
			local health = ply:Health()
			local armor = ply:Armor()
			local oldPos = false
			
			local entsearch = ents.FindInSphere( ragdoll:GetTable().PrevPos , 100 )
			
			for k,v in pairs(entsearch) do
				if v:GetClass() == "prop_ragdoll" then
					oldPos = true
				end
			end
			
			ply:Spawn()
			ply:SetHealth(health)
			ply:SetArmor(armor)
			if oldPos then
				ply:SetPos(ragdoll:GetTable().PrevPos)
			else
				ply:SetPos(ragdoll:GetPos())
			end
			
			ply:SetAngles(Angle(0, ragdoll:GetPhysicsObjectNum(10):GetAngles().Yaw, 0))
			ply:UnSpectate()
			ply:StripWeapons()
			ragdoll:Remove()
			if ply:GetTable().WeaponsForSleep then
				for k,v in pairs(ply.WeaponsForSleep) do
					ply:Give(v)
					ply:GetWeapon(v):SetClip1(ply:GetTable().ClipsForSleep[k])
				end
				ply:StripAmmo()
				for i = 1, 22 do
					ply:GiveAmmo(ply:GetTable().AmmoForSleep[i], PNRP.ConvertAmmoType(i), false)
				end
				local cl_defaultweapon = ply:GetInfo( "cl_defaultweapon" )
				if ( ply:HasWeapon( cl_defaultweapon )  ) then
					ply:SelectWeapon( cl_defaultweapon ) 
				end
				
			else
				GAMEMODE:PlayerLoadout(player)
			end 
		end
		
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

local function DamageSleepers(ent, inflictor, attacker, amount, dmginfo)
	local ownerid = ent:GetTable().OwnerID
	if ownerid and ownerid ~= 0 then
		for k,v in pairs(player.GetAll()) do 
			if v:UniqueID() == ownerid then
				if attacker == GetWorldEntity() then
					amount = 1
					dmginfo:ScaleDamage(0.01)
				end
				if attacker:IsPlayer() and not (dmginfo:IsBulletDamage() or dmginfo:IsExplosionDamage()) then
					amount = 0
					dmginfo:ScaleDamage(0)
				end
				v:SetHealth(v:Health() - amount)
				if v:Health() <= 0 and v:Alive() then
					ExitSleep(v)
					v:SetHealth(1)
					v:TakeDamage(1, inflictor, attacker)
					if v:GetTable().SleepSound then
						v:GetTable().SleepSound:Stop()
					end
					ent:Remove()
				end
			end
		end
	end
end
hook.Add("EntityTakeDamage", "Sleepdamage", DamageSleepers)
