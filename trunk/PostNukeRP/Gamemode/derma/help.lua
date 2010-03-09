--Help Menu Frame

local help = 	{

				"Welcome to PostNumeRP.",
				"",
				"What to do? Find recources and stay alive!",
				"",
				"In Game Commands",
				"------------------------------------------------",
				"TAB - Main Menu",
				"F1 - Help (This Menu)",
				"F2 - Pickup / Take or Release Ownership of Car",
				"F3 - Personal Inventory or when looking at your car, Car Inventory",
				"F4 - Shop Menu",
				"",
				"/save - save's your characters data.",
				"/getallcars - picks up any cars that belong to you in the world",
				"/getcar - picks up the car that you are looking at within 200. You must own the car to pick it up.",
				"/stowgun /stowpwep or /putawaygun - Moved your active gun to inventory.",
				"/dropweap or /dropgun - drops your current weapon.",
				"/dropammo ammoType ammount - Drops the type and ammount of ammo.",
				"          ammoTypes = smg1, buckshot, pistol, 357, ect....",
				"/classmenu - Opens the class change menu.",
				"/shop - Opens shop menu.",
				"/inv - Opens the players inventory.",
				"",
				"Classes",
				"------------------------------------------------",
				"Note: If enabled by admins, there is a cost to changing classes.",
				"",
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
				"Player Death:",
				"------------------------------------------------",
				"When you die, you will drop all your equiped weapons and ammo",
				"to the ground. This does not affect whats in your inventory.",
				"If enabled, there is a % cost to your resources when you die."
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