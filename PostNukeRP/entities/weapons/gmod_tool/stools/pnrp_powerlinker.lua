TOOL.Category = "Other"
TOOL.Name = "Power Linker"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
TOOL.PowerLinkerTool = true

if ( CLIENT ) then
	language.Add( "Tool.pnrp_powerlinker.name", "PNRP - Powerline Linker" )
	language.Add( "Tool.pnrp_powerlinker.desc", "Links power entities in PNRP." )
	language.Add( "Tool.pnrp_powerlinker.0", "Primary: Choose first object to link.  Secondary: Remove all links." )
	language.Add( "Tool.pnrp_powerlinker.1", "Primary: Choose second object to link." )
	language.Add( "undone_powerlink", "Power Link Undone" )
end

function TOOL:LeftClick( trace )
	if not trace.Entity:IsValid() then return false end
	if trace.Entity:IsPlayer() then return false end
	local ply = self:GetOwner()
	
	if (CLIENT) then return true end

	local iNum = self:NumObjects()
	
	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	self:SetObject( iNum + 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
	
	if ( iNum > 0 ) then
		-- Build Rope Vars
		local forcelimit = 0
		local addlength	 = 100
		local material 	 = "cable/cable2"
		local width 	 = 2
		local rigid	 	= false
		
		-- Get information we're about to use
		local Ent1,  Ent2  = self:GetEnt(1),	 self:GetEnt(2)
		local Bone1, Bone2 = self:GetBone(1),	 self:GetBone(2)
		local WPos1, WPos2 = self:GetPos(1),	 self:GetPos(2)
		local LPos1, LPos2 = self:GetLocalPos(1),self:GetLocalPos(2)
		local length = ( WPos1 - WPos2):Length()
		
		if Ent1 == Ent2 then
			self:ClearObjects()
			ply:ChatPrint("You can't link an object to itself!")
			return 
		end
		
		if WPos1:Distance(WPos2) > 500 then
			self:ClearObjects()
			ply:ChatPrint("Cable too long!")
			return
		end
		
		--Do the power link process
		local successful = Ent1:PowerLink(Ent2)
		--ErrorNoHalt("Successful?  "..tostring(successful).."\n")
		if not successful then
			self:ClearObjects()
			return
		end
		
		local newconstraint, rope = constraint.Rope( Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, length, addlength, forcelimit, width, material, rigid )
		
		
		
		-- Clear the objects so we're ready to go again
		self:ClearObjects()

		-- Add to the players undo table

		undo.Create("PowerLink")
			undo.AddEntity( newconstraint )
			if rope then undo.AddEntity( rope ) end
			undo.AddFunction( function (undoData, undoCode)
				Ent1:PowerUnLink()
				constraint.RemoveConstraints( Ent1, "Rope" )
			end)
			undo.SetPlayer( self:GetOwner() )
		undo.Finish()

		self:GetOwner():AddCleanup( "ropeconstraints", newconstraint )		
		self:GetOwner():AddCleanup( "ropeconstraints", rope )
	else
		self:SetStage( iNum+1 )
	end
end

function TOOL:RightClick( trace )
	if not trace.Entity:IsValid() then return false end
	if trace.Entity:IsPlayer() then return false end
	local ply			= self:GetOwner()
	
	if (CLIENT) then return true end
	
	trace.Entity:PowerUnLink()
	constraint.RemoveConstraints( trace.Entity, "Rope" )
	
end

function TOOL:Reload( trace )
	if not trace.Entity:IsValid() then return false end
	if trace.Entity:IsPlayer() then return false end
	if not self:GetOwner():IsAdmin() then return false end
	local ply			= self:GetOwner()
	
	if (CLIENT) then return true end
	
	ply:ChatPrint("NetworkContainer Ent:  "..tostring(trace.Entity.NetworkContainer))
	if table.Count(trace.Entity.DirectLinks) > 0 then
		ply:ChatPrint("DirectLinks:  "..table.ToString(trace.Entity.DirectLinks))
	end
	if trace.Entity.NetworkContainer then
		ply:ChatPrint("LinkedItems:  "..table.ToString(trace.Entity.NetworkContainer.LinkedItems))
	end
end