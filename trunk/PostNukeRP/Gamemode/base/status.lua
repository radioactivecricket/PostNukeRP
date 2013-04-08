
----------------------------------------------------
---		This file includes health regen and
---		endurance drain and regen outside of items.
---		Also controls the sleep systems (of course).
----------------------------------------------------
local PlayerMeta = FindMetaTable("Player")


function StatCheck()
	for k, v in pairs(player.GetAll()) do
		if IsValid(v) then
			if v.HasLoaded then
				local UpdateTime = 0
				if v:GetTable().IsAsleep then
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
					EndUpdateTime = UpdateTime / (1 - (0.5 * (v:GetSkill("Endurance") / 6)))
					if v:GetTable().IsAsleep then
						EndUpdateTime = UpdateTime / 5 
					end
				else
					EndUpdateTime = UpdateTime / (2)
					if v:GetTable().IsAsleep then
						EndUpdateTime = UpdateTime / 5 
					end
				end
				
				--If End and Hunger need to be overidden
				local overide = false
				if v.DevMode or v.AFK then
					overide = true
				end
				
				--Endurance checks
				if v:Alive() and CurTime() - v:GetTable().LastEndUpdate > EndUpdateTime then
					local endur = v:GetTable().Endurance
					
					if v:GetTable().IsAsleep then
						v:GetTable().Endurance = endur + 2
					else
						if not overide then  --Checks for overide
							v:GetTable().Endurance = endur - 1
						end
					end
					
					if v:GetTable().Endurance <= 0 then
						v:ChatPrint("You've fallen unconcious due to fatigue!")
						EnterSleep(v)
					elseif v:GetTable().Endurance >= 100 then
						if v:GetTable().IsAsleep then
							ExitSleep(v)
						end
						v:GetTable().Endurance = 100
					end
					v:GetTable().LastEndUpdate = CurTime()
				end
				SendEndurance( v )
				
				--Hunger checks
				local HunUpdateTime 
				HunUpdateTime = 60 / (2 + ( runModifier / 2 ) )
				if v:Alive() and CurTime() - v:GetTable().LastHunUpdate > HunUpdateTime and not (v:GetTable().IsAsleep) then
					local hunger = v:GetTable().Hunger
					
					if not overide then --Checks for overide
						v:GetTable().Hunger = hunger - 1
						
						if v:GetTable().Hunger <= 0 then
							v:GetTable().Hunger = 0
							
							v:SetHealth( v:Health() - 5 )
							if v:Health() <= 0 then
								timer.Create("kill_timer",  1, 1, function()
										v:Kill()
									end )
							end
						end
					end
					v:GetTable().LastHunUpdate = CurTime()
				end
				SendHunger( v )
			end
		end
	end
end
hook.Add("Think", "StatCheck", StatCheck)

-----------------------------
---	Exit/Enter Sleep
-----------------------------
function EnterSleep ( ply )
	local IsSleeping = ply:GetTable().IsAsleep
	local curEndurance = ply:GetTable().Endurance
	
	if ply.AFK then
		ply:ChatPrint("You can not sleep while AFK.")
		return
	end
	
	if IsSleeping == false and curEndurance < 100 then
		if not ply:GetTable().SleepSound then
			ply:GetTable().SleepSound = CreateSound(ply, "npc/ichthyosaur/water_breath.wav")
		end
		ply:GetTable().IsAsleep = true
		ply:GetTable().SleepGodCheck = true
		ply:GetTable().SleepSound:PlayEx(0.10, 100)
		
		
		if ply:InVehicle() then
			ply:Freeze(true)
		else
			ply:Freeze(true)
			ply:CreateRagdoll()
			ply:SetRenderMode(1)
			ply:SetColor( Color(0,0,0,0) )
			local ragdoll = ply:GetRagdollEntity()
			ply.SleepRagdoll = ragdoll
			ply.OldColGroup = ply:GetCollisionGroup()
			ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			
			if ply:HasWeapon( "gmod_rp_hands" ) then
				ply:SelectWeapon( "gmod_rp_hands")
			end
			-- ply:GetTable().WeaponsForSleep = {}
			-- ply:GetTable().ClipsForSleep = {}
			-- ply:GetTable().AmmoForSleep = {}
			-- for k,v in pairs(ply:GetWeapons( )) do
				-- ply:GetTable().WeaponsForSleep[k] = v:GetClass()
				-- ply:GetTable().ClipsForSleep[k] = v:Clip1()
			-- end
			
			-- for i = 1, 22 do
				-- ply:GetTable().AmmoForSleep[i] = ply:GetAmmoCount(PNRP.ConvertAmmoType(i))
			-- end
			
			-- local ragdoll = ents.Create("prop_ragdoll")
			-- ragdoll:SetPos(ply:GetPos())
			-- ragdoll:SetAngles(Angle(0,ply:GetAngles().Yaw,0))
			-- ragdoll:SetModel(ply:GetModel())
			-- ragdoll:Spawn()
			-- ragdoll:Activate()
			-- ragdoll:SetVelocity(ply:GetVelocity())
			-- --ragdoll.OwnerINT = player:EntIndex()
			-- ragdoll:GetTable().PrevPos = ply:GetPos()
			
			-- ply:StripWeapons()
			-- ply:Spectate(OBS_MODE_CHASE)
			-- ply:SpectateEntity(ragdoll)
			-- ply:GetTable().SleepRagdoll = ragdoll
			-- ragdoll:GetTable().OwnerID = ply:UniqueID()
			-- ragdoll.Owner = player
			-- ragdoll:SetNetworkedString("Owner", ply:Nick())
		end
		
		net.Start("sleepeffects")
			net.WriteBit(true)
		net.Send(ply)
	end
end
util.AddNetworkString("sleepeffects")

function EnterSleepCmd( ply )
	if not ply:IsOutside() then
		if not ply:Crouching() then
			if ply:GetTable().Endurance < 80 then
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
	local IsSleeping = ply:GetTable().IsAsleep
	local curEndurance = ply:GetTable().Endurance
	--ply:GetTable().SleepSound
	if IsSleeping == true then
		ply:GetTable().IsAsleep = false
		if ply:GetTable().SleepSound then
			ply:GetTable().SleepSound:Stop()
		end
		if ply:InVehicle() then
			ply:Freeze(false)
		else
			ply:Freeze(false)
			ply:SetRenderMode(0)
			ply:SetColor( Color(255,255,255,255) )
			ply.SleepRagdoll:Remove()
			ply:SetCollisionGroup(ply.OldColGroup)
			-- local ragdoll = ply:GetTable().SleepRagdoll
			-- local health = ply:Health()
			-- local armor = ply:Armor()
			-- local hunger = ply:GetTable().Hunger
			-- local oldPos = false
			
			-- local entsearch = ents.FindInSphere( ragdoll:GetTable().PrevPos , 100 )
			
			-- for k,v in pairs(entsearch) do
				-- if v:GetClass() == "prop_ragdoll" then
					-- oldPos = true
				-- end
			-- end
			
			-- ply:Spawn()
			-- ply:SetHealth(health)
			-- ply:SetArmor(armor)
			-- ply:GetTable().Hunger = hunger
			-- ply:GetTable().SleepGodCheck = false
			-- if oldPos then
				-- ply:SetPos(ragdoll:GetTable().PrevPos)
			-- else
				-- ply:SetPos(ragdoll:GetPos())
			-- end
			
			-- ply:SetAngles(Angle(0, ragdoll:GetPhysicsObjectNum(10):GetAngles().Yaw, 0))
			-- ply:UnSpectate()
			-- ply:StripWeapons()
			-- ragdoll:Remove()
			-- --Runs this a little after spawn to help with lag issues
			-- ply:ChatPrint("Picking up gear...")
			-- timer.Create(ply:UniqueID()..tostring(os.time())..tostring(os.date()), 3, 1, function()  
				-- if ply:GetTable().WeaponsForSleep then
					-- for k,v in pairs(ply.WeaponsForSleep) do
						-- local currentWep = ply:Give(v)
						-- currentWep:SetClip1(ply:GetTable().ClipsForSleep[k])
					-- end
					-- ply:StripAmmo()
					-- for i = 1, 22 do
						-- ply:GiveAmmo(ply:GetTable().AmmoForSleep[i], PNRP.ConvertAmmoType(i), false)
					-- end
									
					-- local cl_defaultweapon = ply:GetInfo( "cl_defaultweapon" )
					-- if ( ply:HasWeapon( cl_defaultweapon )  ) then
						-- ply:SelectWeapon( cl_defaultweapon ) 
					-- end
				
				-- else
					-- GAMEMODE:PlayerLoadout(player)
				-- end 
				
				-- --Checks to make sure the player has the default weapons
				-- for _,v in pairs(PNRP.DefWeps) do
					-- if !ply:HasWeapon( v ) then
						-- ply:Give( v )
					-- end
				-- end
				
				-- ply:ConCommand("pnrp_save")
				-- ply:ChatPrint("Timer has run")
			-- end)
		end
		
		net.Start("sleepeffects")
			net.WriteBit(false)
		net.Send(ply)
	end
end

function ExitSleepCmd( ply )
	if ply:GetTable().IsAsleep then
		ExitSleep( ply )
	else
		ply:ChatPrint("You're not asleep!")
	end
end
concommand.Add( "pnrp_wake", ExitSleepCmd )
PNRP.ChatConCmd( "/wake", "pnrp_wake" )

--[[local function DamageSleepers(ent, inflictor, attacker, amount, dmginfo)
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
hook.Add("EntityTakeDamage", "Sleepdamage", DamageSleepers)]]--

------------------------------
-- Variable sends
------------------------------

function SendEndurance( ply )
	net.Start("endurancemsg")
		net.WriteDouble(ply:GetTable().Endurance)
	net.Send(ply)
end
util.AddNetworkString("endurancemsg")

function SendHunger( ply )
	net.Start("hungermsg")
		net.WriteDouble(ply:GetTable().Hunger)
	net.Send(ply)
end
util.AddNetworkString("hungermsg")

function PlayerMeta:GiveEndurance( amount )
	self:GetTable().Endurance = self:GetTable().Endurance + amount
	if self:GetTable().Endurance > 100 then 
		self:GetTable().Endurance = 100
	end
	SendEndurance( self )
end

function PlayerMeta:TakeEndurance( amount )
	self:GetTable().Endurance = self:GetTable().Endurance - amount
	if self:GetTable().Endurance < 0 then
		self:GetTable().Endurance = 0
	end
	SendEndurance( self )
end

function PlayerMeta:GiveHunger( amount )
	self:GetTable().Hunger = self:GetTable().Hunger + amount
	if self:GetTable().Hunger > 100 then
		self:GetTable().Hunger = 100
	end
	SendHunger( self )
end

function PlayerMeta:TakeHunger( amount )
	self:GetTable().Hunger = self:GetTable().Hunger - amount
	if self:GetTable().Hunger < 0 then
		self:GetTable().Hunger = 0
	end
	SendHunger( self )
end

function EndDebug( ply )
	ply:ChatPrint("Your endurance is at "..tostring(ply:GetTable().Endurance)..".")
end
concommand.Add( "pnrp_enddebug", EndDebug )