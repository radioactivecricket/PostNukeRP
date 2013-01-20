
local function DrunknessEffects()
	local person = LocalPlayer()
	local val = {}
	
	if not person.Drunkness then
		person.Drunkness = 0
	end
	
	if not person.DrnkEffects then
		person.DrnkEffects = false
	end
	
	if person.Drunkness > 20 then
		if person.DrnkEffects == false then
			person.DrnkEffects = true
			--person:ChatPrint("Drunk effects on.")
			hook.Add("RenderScreenspaceEffects", "drunkeffects", function()
					local mtnBlurLvl = math.Clamp(LocalPlayer().Drunkness-20,0,80)/80
					DrawMotionBlur( 0.4, 0.4+(0.4*mtnBlurLvl), (0.02*mtnBlurLvl) )
				end)
		end
	else
		if person.DrnkEffects == true then
			person.DrnkEffects = false
			--person:ChatPrint("Drunk effects off.")
			hook.Remove("RenderScreenspaceEffects", "drunkeffects")
		end
	end
	
	if person.Drunkness > 0 then
		local mtnBlurLvl = LocalPlayer().Drunkness/100
		
		val.pitch, val.yaw, val.roll = person:EyeAngles().p, person:EyeAngles().y, person:EyeAngles().r
		
		val.pitch = val.pitch + (( 0.2 * math.cos( 2*CurTime() )) * mtnBlurLvl)
		val.yaw = val.yaw + (( 0.3 * math.sin( CurTime() )) * mtnBlurLvl)
		val.roll = val.roll + (( 0.1 * math.sin( CurTime() )) * mtnBlurLvl)
		
		if (person:Alive() ) then person:SetEyeAngles(Angle(val.pitch, val.yaw, val.roll )) end
	end
end
hook.Add("Think", "DrunkTilt", DrunknessEffects)

function SetDrunkness()
	local drunkAmnt = net.ReadUInt(8)
	
	LocalPlayer().Drunkness = drunkAmnt
end
net.Receive( "pnrp_SetDrunkness", SetDrunkness )