include('shared.lua')
 
ENT.RenderGroup = RENDERGROUP_BOTH
 
---------------------------------------------------------
--   Name: Draw
--   Desc: Draw it!
---------------------------------------------------------
function ENT:Draw()
	self.Entity:DrawModel()
end
 
---------------------------------------------------------
--   Name: DrawTranslucent
--   Desc: Draw translucent
---------------------------------------------------------
function ENT:DrawTranslucent()
 
	-- This is here just to make it backwards compatible.
	-- You shouldn't really be drawing your model here unless it's translucent
 
	self:Draw()
 
end
 
---------------------------------------------------------
--   Name: BuildBonePositions
--   Desc: 
---------------------------------------------------------
function ENT:BuildBonePositions( NumBones, NumPhysBones )
 
	-- You can use this section to position the bones of
	-- any animated model using self:SetBonePosition( BoneNum, Pos, Angle )
 
	-- This will override any animation data and isn't meant as a 
	-- replacement for animations. We're using this to position the limbs
	-- of ragdolls.
 
end
 
 
 
---------------------------------------------------------
--   Name: SetRagdollBones
--   Desc: 
---------------------------------------------------------
function ENT:SetRagdollBones( bIn )
 
	-- If this is set to true then the engine will call 
	-- DoRagdollBone (below) for each ragdoll bone.
	-- It will then automatically fill in the rest of the bones
 
	self.m_bRagdollSetup = bIn
 
end
 
 
---------------------------------------------------------
--   Name: DoRagdollBone
--   Desc: 
---------------------------------------------------------
function ENT:DoRagdollBone( PhysBoneNum, BoneNum )
 
	-- self:SetBonePosition( BoneNum, Pos, Angle )
 
end

function GrubMenu( )
	local grubEnt = net:ReadEntity()
	local partnerEnt = net:ReadEntity()
	local availFood = math.Round(net:ReadDouble())
	local foodLevel = math.Round(net:ReadDouble())
	local ply = LocalPlayer()
	
	local w = 300
	local h = 400
	local title = "Grub Menu"

	local grub_frame = vgui.Create("DFrame")
	--smelt_frame:SetPos( (ScrW()/2) - (w / 2), (ScrH()/2) - (h / 2))
	grub_frame:SetSize( w, h )
	grub_frame:SetTitle( title )
	grub_frame:SetVisible( true )
	grub_frame:SetDraggable( true )
	grub_frame:ShowCloseButton( true )
	grub_frame:Center()
	grub_frame:MakePopup()
	
	local PartnerLabel = vgui.Create("DLabel", grub_frame)
		PartnerLabel:SetPos( 25, 75 )
		PartnerLabel:SetColor( Color( 255, 255, 255, 255 ) )
		if IsValid(partnerEnt) then
			PartnerLabel:SetText( "Has breeding partner!" )
		else
			PartnerLabel:SetText( "No breeding partner!" )
		end
		PartnerLabel:SizeToContents()
		
	local FoodLabel = vgui.Create("DLabel", grub_frame)
		FoodLabel:SetPos( 25, 100 )
		FoodLabel:SetColor( Color( 255, 255, 255, 255 ) )
		FoodLabel:SetText( "Food Level:  "..tostring(foodLevel) )
		FoodLabel:SizeToContents()
	
	local foodNumberWang = vgui.Create( "DNumberWang", grub_frame )
			foodNumberWang:SetPos(30, 240 )
			foodNumberWang:SetMin( 0 )
			foodNumberWang:SetMax( availFood )
			foodNumberWang:SetDecimals( 0 )
			foodNumberWang:SetValue( 0 )
	
	local FeedBtn = vgui.Create( "DButton" )
	FeedBtn:SetParent( grub_frame )
	FeedBtn:SetText( "Feed" )
	FeedBtn:SetPos( grub_frame:GetWide() / 2 - 125, 270 )
	FeedBtn:SetSize( 125, 30 )
	FeedBtn.DoClick = function ()
		local lFood = foodNumberWang:GetValue()
		if lFood < 0 then lFood = 0 end
		if lFood > availFood then lFood = availFood end
		net.Start("grubFeed")
			net.WriteDouble(lFood)
			net.WriteEntity(ply)
			net.WriteEntity(grubEnt)
		net.SendToServer()
		grub_frame:Close()
	end
	
	local PartnerBtn = vgui.Create( "DButton" )
	PartnerBtn:SetParent( grub_frame )
	PartnerBtn:SetText( "Set Partner" )
	PartnerBtn:SetPos( grub_frame:GetWide() / 2 - 125, 300 )
	PartnerBtn:SetSize( 125, 30 )
	PartnerBtn.DoClick = function ()
		net.Start("grubSelect")
			net.WriteEntity(ply)
			net.WriteEntity(grubEnt)
		net.SendToServer()
		grub_frame:Close()
	end
end
net.Receive("grub_menu", GrubMenu)