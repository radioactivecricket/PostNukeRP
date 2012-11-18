TOOL.Category = "Other"
TOOL.Name = "Monster Node Placer"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 

if ( CLIENT ) then
	language.Add( "Tool.pnrp_nodemaker.name", "PNRP Monster Node Placer" )
	language.Add( "Tool.pnrp_nodemaker.desc", "Spawns and updates nodes for PNRP." )
	language.Add( "Tool.pnrp_nodemaker.0", "Primary: Create/Update Monster Node" )
	language.Add( "undone_monsternode", "Undone Monster Node" )
end

TOOL.ClientConVar[ "distance" ] = 1000
TOOL.ClientConVar[ "res" ] = 1
TOOL.ClientConVar[ "ant" ] = 1
TOOL.ClientConVar[ "zom" ] = 1
TOOL.ClientConVar[ "mound" ] = 1
TOOL.ClientConVar[ "indoor" ] = 0
TOOL.ClientConVar[ "targindex" ] = -1
 
function TOOL:LeftClick( trace )
	if trace.Entity and trace.Entity:IsPlayer() then return false end
	local ply			= self:GetOwner()
	if not ply:IsAdmin() then return false end
	
	if (CLIENT) then return true end
	
	local distance		= self:GetClientNumber("distance", 1000)
	local res			= util.tobool(self:GetClientNumber("res", 1))
	local ant			= util.tobool(self:GetClientNumber("ant", 1))
	local zom			= util.tobool(self:GetClientNumber("zom", 1))
	local mound			= util.tobool(self:GetClientNumber("mound", 1))
	local indoor		= util.tobool(self:GetClientNumber("indoor", 0))
	
	if trace.Entity:GetClass() == "mobspawn_gridbuilder" then
		trace.Entity:SetNWInt("distance", distance)
		trace.Entity:SetNWBool("spwnsRes", res)
		trace.Entity:SetNWBool("spwnsAnt", ant)
		trace.Entity:SetNWBool("spwnsZom", zom)
		trace.Entity:SetNWBool("infMound", mound)
		trace.Entity:SetNWBool("infIndoor", indoor)
	else
		local ent = ents.Create ("mobspawn_gridbuilder")
		
		ent:SetPos( trace.HitPos + Vector(0, 0, 50) )
		ent:Spawn()
		ent:GetPhysicsObject():EnableMotion(false)
		ent:SetMoveType(MOVETYPE_NONE)
		
		ent:SetNWInt("distance", distance)
		ent:SetNWBool("spwnsRes", res)
		ent:SetNWBool("spwnsAnt", ant)
		ent:SetNWBool("spwnsZom", zom)
		ent:SetNWBool("infMound", mound)
		ent:SetNWBool("infIndoor", indoor)
		
		undo.Create("MonsterNode")
			undo.AddEntity( ent )
			undo.SetPlayer( ply )
		undo.Finish()
		
		ply:AddCleanup( "mobspawn_gridbuilders", ent )
	end
end
 
function TOOL:RightClick( trace )
	local ply			= self:GetOwner()
	if not ply:IsAdmin() then return false end
	
	if (CLIENT) then return true end
	
	if self:GetClientNumber("targindex", -1) == -1 then
		if trace.Entity:IsValid() and trace.Entity:GetClass() == "mobspawn_gridbuilder" then
			ply:ConCommand("pnrp_nodemaker_targindex "..tostring(trace.Entity:EntIndex())) 
			ply:ChatPrint( "Node selected...")
		else
			ply:ChatPrint( "You must select a node first.")
			return false
		end
	else
		if trace.Entity:IsValid() and trace.Entity:IsDoor() then
			local myNode = ents.GetByIndex( self:GetClientNumber("targindex") )
			
			myNode:SetNWEntity( "infLinked", trace.Entity )
			ply:ConCommand("pnrp_nodemaker_targindex -1")
			ply:ChatPrint( "Door linked.")
		elseif trace.Entity:IsValid() and trace.Entity:EntIndex() == self:GetClientNumber("targindex") then
			trace.Entity:SetNWEntity( "infLinked", nil )
			ply:ConCommand("pnrp_nodemaker_targindex -1")
			ply:ChatPrint( "Link cancelled.")
		else
			ply:ChatPrint( "You can only link to doors.")
			return false
		end
	end
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "Monster Node Maker", Description = "Makes nodes for the PNRP spawner" })
	
	-- panel:AddControl("TextBox", {
		-- Label = "Distance:",
		-- MaxLength = 255,
		-- Text = "Enter an integer distance",
		-- Command = "pnrp_nodemaker_distance",
	-- })
	panel:AddControl("Slider", {
	    Label = "Distance",
	    Type = "Integer",
	    Min = "0",
	    Max = "5000",
	    Command = "pnrp_nodemaker_distance"
	})

	
	panel:AddControl("CheckBox", {
		Label = "Spawns Resources",
		Command = "pnrp_nodemaker_res"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Spawns Antlions",
		Command = "pnrp_nodemaker_ant"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Spawns Zombies",
		Command = "pnrp_nodemaker_zom"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Spawns Mounds",
		Command = "pnrp_nodemaker_mound"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Indoor Spawner",
		Command = "pnrp_nodemaker_indoor"
	})
end
