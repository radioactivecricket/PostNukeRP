local pnrp_frame
local PNFrame = false

function PNRP.PNRP_Frame()

	if PNFrame then return end 
	PNFrame = true
	
	pnrp_frame = vgui.Create( "DFrame" )
	
	function pnrp_frame:Close()                  
		PNFrame = false                  
		self:SetVisible( false )
		self:Remove()          
	end 
	
	return pnrp_frame
end