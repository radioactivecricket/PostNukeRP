
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

	umsg.Start("pnrp_SetSkill",self)
	umsg.String(skill)
	umsg.Short(int)
	umsg.End()
end

function PlayerMeta:IncSkill(skill,int)
	if !self.Skills[skill] then self.Skills[skill] = 0 end

	self.Skills[skill] = self.Skills[skill] + int

	umsg.Start("pnrp_SetSkill",self)
	umsg.String(skill)
	umsg.Short(self:GetSkill(skill))
	umsg.End()
end

function PlayerMeta:DecSkill(skill,int)
	if !self.Skills[skill] then self.Skills[skill] = 0 return end
	
	self.Skills[skill] = self.Skills[skill] - int
	if self.Skills[skill] < 0 then self.Skills[skill] = 0 end
	umsg.Start("pnrp_SetSkill",self)
	umsg.String(skill)
	umsg.Short(self:GetSkill(skill))
	umsg.End()
end

function PlayerMeta:GetXP()
	return self.Experience or 0
end

function PlayerMeta:SetXP(int)
	if !self.Experience then self.Experience = 0 end

	self.Experience = int

	umsg.Start("pnrp_SetXP",self)
	umsg.Long(int)
	umsg.End()
end

function PlayerMeta:IncXP(int)
	if !self.Experience then self.Experience = 0 end

	self.Experience = self.Experience + int

	umsg.Start("pnrp_SetXP",self)
	umsg.Long(self:GetXP())
	umsg.End()
end

function PlayerMeta:DecXP(int)
	if !self.Experience then self.Experience = 0 return end
	
	self.Experience = self.Experience - int
	if self.Experience < 0 then self.Experience = 0 end
	umsg.Start("pnrp_SetXP",self)
	umsg.Long(self:GetXP())
	umsg.End()
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
	if not killer:IsPlayer() then return end
	if GetConVarNumber("pnrp_propExp") == 0 then
		if weapon:GetClass() == "prop_physics" then return end
	end
	
	if victim:GetClass() == "npc_antlionguard" then
		killer:IncXP(5)
	else
		killer:IncXP(1)
	end
end
hook.Add( "OnNPCKilled", "GiveDeathXP", DeathXP )
