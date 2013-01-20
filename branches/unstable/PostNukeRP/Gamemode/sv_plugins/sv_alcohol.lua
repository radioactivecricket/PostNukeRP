
local PlayerMeta = FindMetaTable( "Player" )
util.AddNetworkString("pnrp_SetDrunkness")

function PlayerMeta:GiveDrunkness( amount )
	if not self.Drunkness then
		self.Drunkness = 0
	end
	
	self.Drunkness = math.Round(self.Drunkness + amount)
	
	if self.Drunkness > 100 then self.Drunkness = 100 end
	
	net.Start("pnrp_SetDrunkness")
		net.WriteUInt(math.Round(self.Drunkness), 8)
	net.Send(self)
end

function PlayerMeta:TakeDrunkness( amount )
	if not self.Drunkness then
		self.Drunkness = 0
	end
	
	self.Drunkness = math.Round(self.Drunkness - amount)
	
	if self.Drunkness < 0 then self.Drunkness = 0 end
	
	net.Start("pnrp_SetDrunkness")
		net.WriteUInt(math.Round(self.Drunkness), 8)
	net.Send(self)
end

function PlayerMeta:SetDrunkness( amount )
	if not self.Drunkness then
		self.Drunkness = 0
	end
	
	self.Drunkness = math.Round(amount)
	
	if self.Drunkness < 0 then self.Drunkness = 0 end
	if self.Drunkness > 100 then self.Drunkness = 100 end
	
	net.Start("pnrp_SetDrunkness")
		net.WriteUInt(math.Round(self.Drunkness), 8)
	net.Send(self)
end

local function DrunkCheck()
	for k, v in pairs(player.GetAll()) do
		if IsValid(v) then
			if v.HasLoaded then
				if not v.LastDrnkUpdate then
					v.LastDrnkUpdate = CurTime()
				end
				local UpdateTime = 0
				if v:GetTable().IsAsleep then
					UpdateTime = 5
				else
					UpdateTime = 30
				end
				
				local DrnkUpdateTime 
				if v:Team() == TEAM_WASTELANDER then
					DrnkUpdateTime = UpdateTime / (2 + (0.5 * (v:GetSkill("Endurance") / 6)))
					if v:GetTable().IsAsleep then
						DrnkUpdateTime = UpdateTime / 5 
					end
				else
					DrnkUpdateTime = UpdateTime / (1)
					if v:GetTable().IsAsleep then
						DrnkUpdateTime = UpdateTime / 5 
					end
				end
				
				if v:Alive() and CurTime() - v:GetTable().LastDrnkUpdate > DrnkUpdateTime then
					local drnkness = v.Drunkness
					
					if v:GetTable().IsAsleep then
						v:TakeDrunkness( 5 )
					else
						v:TakeDrunkness( 1 )
					end
					v:GetTable().LastDrnkUpdate = CurTime()
				end
				if (not v:Alive()) and v.Drunkness > 0 then
					v:SetDrunkness( 0 )
				end
			end
		end
	end
end
hook.Add("Think", "DrunkCheck", DrunkCheck)
