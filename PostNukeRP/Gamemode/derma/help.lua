--Help Menu Frame

local help = 	{

				"Welcome to PostNumeRP.",
				"",
				"What to do? Find recources and stay alive!",
				"",
				"In Game Commands",
				"------------------------------------------------",
				"TAB - Main Menu",
				"",
				"Classes",
				"------------------------------------------------",
				"WASTELANDER:",	
				"Bonus to HP",
				"Bonus to Endurance (In Dev)",
				"",
				"SCAVENGER:",
				"Bonus to Run Speed",
				"Bonus to Gathering Speed",
				"",
				"ENGINEER:",	
				"Ability to create Weapons and Ammo",
				"",
				"SCIENCE:",		
				"Ability to create Med Kits",
				"Ability to create Explosives",
				"",
				"CULTIVATOR:",	
				"Ability to create Food (In Dev)",
				"",
				}
				
function HelpPanel() 
	local HelpFrame = vgui.Create("DFrame")
		HelpFrame:SetSize(700, 700)
		HelpFrame:SetPos(ScrW() / 2 - HelpFrame:GetWide() / 2, ScrH() / 2 - HelpFrame:GetTall() / 2)
		HelpFrame:SetTitle( "Help Menu" )
		HelpFrame:SetBackgroundBlur(true)
		HelpFrame:SetVisible( true )
		HelpFrame:SetDraggable( true )
		HelpFrame:ShowCloseButton( true )
		HelpFrame:MakePopup()
		
	local pnlList = vgui.Create("DPanelList", HelpFrame)
		pnlList:SetPos(20, 40)
		pnlList:SetSize(HelpFrame:GetWide() - 40, HelpFrame:GetTall() - 60)
		pnlList:EnableVerticalScrollbar(true) 
		pnlList:EnableHorizontal(false) 
		pnlList:SetSpacing(0)
		pnlList:SetPadding(10)
		
		for k, v in pairs( help ) do
			local ReadThis = vgui.Create( "DLabel", HelpFrame )
				ReadThis:SetText( v )
				pnlList:AddItem( ReadThis )
		end	
		
end
concommand.Add("pnrp_help", HelpPanel)

--EOF