
--[[
---------------------------------------------------
---------------------SKILLS------------------------
---------------------------------------------------
-	This will basically be using the same system  -
- as skills.  It should keep it managable and  -
- extendable that way.							  -
---------------------------------------------------
--]]

CreateConVar("pnrp_propExp","0",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

function PlayerMeta:GetSkill(skill)
	return self.Skills[skill] or 0
end

function PlayerMeta:SetSkill(skill,int)
	if !self.Skills[skill] then self.Skills[skill] = 0 end

	self.Skills[skill] = int
	
	if int == nil then int = 0 end
	
	net.Start("pnrp_SetSkill")
		net.WriteString(skill)
		net.WriteDouble(int)
	net.Send(self)
end
util.AddNetworkString("pnrp_SetSkill")

function PlayerMeta:IncSkill(skill,int)
	if !self.Skills[skill] then self.Skills[skill] = 0 end

	self.Skills[skill] = self.Skills[skill] + int
	
	net.Start("pnrp_SetSkill")
		net.WriteString(skill)
		net.WriteDouble(tonumber(self:GetSkill(skill)))
	net.Send(self)

end

function PlayerMeta:DecSkill(skill,int)
	if !self.Skills[skill] then self.Skills[skill] = 0 return end
	
	self.Skills[skill] = self.Skills[skill] - int
	if self.Skills[skill] < 0 then self.Skills[skill] = 0 end
	
	net.Start("pnrp_SetSkill")
		net.WriteString(skill)
		net.WriteDouble(tonumber(self:GetSkill(skill)))
	net.Send(self)
	
end

function PlayerMeta:GetXP()
	return self.Experience or 0
end

function PlayerMeta:SetXP(int)
	if !self.Experience then self.Experience = 0 end

	self.Experience = int

	net.Start("pnrp_SetXP")
		net.WriteDouble(tonumber(int))
	net.Send(self)
end
util.AddNetworkString("pnrp_SetXP")

function PlayerMeta:IncXP(int)
	if !self.Experience then self.Experience = 0 end

	self.Experience = self.Experience + int
	
	net.Start("pnrp_SetXP")
		net.WriteDouble(tonumber(self:GetXP()))
	net.Send(self)

end

function PlayerMeta:DecXP(int)
	if !self.Experience then self.Experience = 0 return end
	
	self.Experience = self.Experience - int
	if self.Experience < 0 then self.Experience = 0 end
	
	net.Start("pnrp_SetXP")
		net.WriteDouble(tonumber(self:GetXP()))
	net.Send(self)
	
end

local function UpgradeSkill(ply, cmd, args)
	local skill = args[1]
	local skillLvl = ply:GetSkill(skill)
	local baseCost = PNRP.Skills[skill].basecost
	local maxLvl = PNRP.Skills[skill].maxlvl
	
	if skillLvl >= maxLvl then 
		ply:ChatPrint("You cannot upgrade this skill any higher!")
		return
	end
	
	local expCost = baseCost * (2^(skillLvl))
	if ply:GetXP() < expCost then
		ply:ChatPrint("You don't have enough experience to upgrade this skill!")
		return
	end
	
	ply:IncSkill(skill, 1)
	ply:DecXP(expCost)
	
	if skill == "Athletics" then
		if ply:Team() == TEAM_SCAVENGER then
			ply:SetRunSpeed( 325 + (ply:GetSkill("Athletics") * 10) ) 
		else
			ply:SetRunSpeed( 295 + (ply:GetSkill("Athletics") * 10) )
		end
	end
end
concommand.Add( "pnrp_upgradeskill", UpgradeSkill )

local function AddXPPoints(ply, cmd, args)
	if ply:IsAdmin() then
		local amount = tonumber(args[1])
		
		ply:IncXP(amount)
		ply:ChatPrint("Added "..tostring(amount).." xp to you!")
	end
end
concommand.Add( "pnrp_addxp", AddXPPoints )

--[[
	XP from NPC deaths!
--]]

function DeathXP( victim, killer, weapon )
	if victim.hasBackpack then
		local pos = victim:GetPos()+ Vector(0,0,20)
		local ent = ents.Create("msc_backpack")
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(pos)
		ent.contents = victim.packTbl
		ent:Spawn()
	end
	
	if not killer:IsPlayer() then return end
	if GetConVarNumber("pnrp_propExp") == 0 then
		if weapon:GetClass() == "prop_physics" then return end
	end
	
	if victim:GetClass() == "npc_antlionguard" then
		killer:IncXP(30)
	elseif victim:GetClass() == "npc_fastzombie" then
		killer:IncXP(3)
	elseif victim:GetClass() == "npc_poisonzombie" then
		killer:IncXP(3)
	elseif victim:GetClass() == "npc_combine_s" then
		killer:IncXP(10)
	else
		killer:IncXP(1)
	end
	
	local spawnMod
	if killer:Team() == TEAM_WASTELANDER then
		spawnMod = 20
	else
		spawnMod = 0
	end
	
	--For now, drops will go here.
	if victim:GetClass() == "npc_antlion" then
		if math.random(1,100) <= 30 + spawnMod then
			if math.random(1,100) <= 30 + (spawnMod / 2) then
				PNRP.Items["fuel_grubfood"].Create(killer, PNRP.Items["fuel_grubfood"].Ent, victim:GetPos()+ Vector(0,0,20))
			else
				PNRP.Items["food_rawant"].Create(killer, PNRP.Items["food_rawant"].Ent, victim:GetPos()+ Vector(0,0,20))
			end
		end
	elseif victim:GetClass() == "npc_zombie" or victim:GetClass() == "npc_fastzombie" or victim:GetClass() == "npc_poisonzombie" then
		if math.random(1,100) <= 20 + spawnMod then
			PNRP.Items["food_rawhead"].Create(killer, PNRP.Items["food_rawhead"].Ent, victim:GetPos()+ Vector(0,0,20))
		end
	elseif victim:GetClass() == "npc_antlionguard" then
		if math.random(1,100) <= 20 + spawnMod then
			if math.random(1,100) <= 60 then
				PNRP.Items["fuel_grubfood"].Create(killer, PNRP.Items["fuel_grubfood"].Ent, victim:GetPos()+ Vector(0,0,20))
			else
				PNRP.Items["food_rawguard"].Create(killer, PNRP.Items["food_rawguard"].Ent, victim:GetPos()+ Vector(0,0,20))
			end
		end
	end
end
hook.Add( "OnNPCKilled", "GiveDeathXP", DeathXP )
