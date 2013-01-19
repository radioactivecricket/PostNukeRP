--Help Menu Frame

function HelpPanel()
	local w = 810
	local h = 770
	local HelpFrame = vgui.Create("DFrame")
		HelpFrame:SetSize(w, h)
		HelpFrame:SetPos(ScrW() / 2 - HelpFrame:GetWide() / 2, ScrH() / 2 - HelpFrame:GetTall() / 2)
		HelpFrame:SetTitle( "Help Menu" )
		HelpFrame:SetBackgroundBlur(true)
		HelpFrame:SetVisible( true )
		HelpFrame:SetDraggable( true )
		HelpFrame:ShowCloseButton( true )
		HelpFrame:MakePopup()
		HelpFrame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", HelpFrame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_1b.png" )
			screenBG:SetKeepAspect()
			screenBG:SizeToContents()
			screenBG:SetSize(HelpFrame:GetWide(), HelpFrame:GetTall())
			
		local setTxt = vgui.Create("HTML", HelpFrame)
			setTxt:SetMultiline(true)
			setTxt:OpenURL(PNRP_WIKIPath)
			setTxt:SetPos(50,40)
			setTxt:SetSize(HelpFrame:GetWide()-100, HelpFrame:GetTall()-100)
end

function HelpPanelOld()
	local textColor = Color(200,200,200,255)
	
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
		pnlList:SetSpacing(2)
		pnlList:SetPadding(10)
		pnlList.Paint = function()
			draw.RoundedBox( 8, 0, 0, pnlList:GetWide(), pnlList:GetTall(), Color( 50, 50, 50, 255 ) )
		end
		
		local helpIntro = 	{
				"Welcome to PostNukeRP",
				"What to do? Find resources, stay alive, and help your team members!"
				}
			for k, v in pairs( helpIntro ) do
				local ReadThis = vgui.Create( "DLabel" )
				ReadThis:SetTextColor(textColor)
					ReadThis:SetText( v )
					pnlList:AddItem( ReadThis )
			end			
			
			
		local InGameComDCats = vgui.Create("DCollapsibleCategory", pnlList)
			InGameComDCats:SetSize( pnlList:GetWide()-50, 50 ) -- Keep the second number at 50
			InGameComDCats:SetExpanded( 0 ) -- Expanded when popped up
			InGameComDCats:SetLabel( "In Game Commands" )
			 
			InGameComList = vgui.Create( "DPanelList" )
			InGameComList:SetAutoSize( true )
			InGameComList:SetSpacing( 0 )
			InGameComList:EnableHorizontal( false )
			InGameComList:EnableVerticalScrollbar( true )
			 
			InGameComDCats:SetContents( InGameComList )

			local helpCommands = 	{

				"TAB - Main Menu",
				"F1 - Help (This Menu)",
				"F2 - Pickup item",
				"F3 - Personal Inventory or when looking at your car, Car Inventory",
				"F4 - Shop Menu",
				"F12 - Set / Release Ownership.",
				"",
				"/ooc or // - Global Chat. Anyone can see this even when Voice Limiter is on.",
				"/save - save's your characters data.",
				"/getallcars - picks up any and all cars that belong to you in the world",
				"/eq /equipment - Opens the Equipment Menu",
				"/getcar - picks up the car that you are looking at within 200 units. You must own the car to pick it up.",
				"/stowgun /stowwep or /putawaygun - Moved your active gun to inventory.",
				"/dropwep or /dropgun - drops your current weapon.",
				"/dropammo ammoType ammount - Drops the type and ammount of ammo.",
				"          ammoTypes = smg1, buckshot, pistol, 357, ect....",
				"/classmenu - Opens the class change menu.",
				"/shop - Opens shop menu.",
				"/inv - Opens the players inventory.",
				"/setowner - Set / Release Ownership.",
				"/sleep - When the players Endurance reaches a certin point the player is able to sleep.",
				"          Players also get a bonus to HP recovery while asleep and the player will automatically wake back up when Endurance is full. ",
				"/wake - Wakes the player from the sleeping state.",
				"/salvage - Salvages the item that you are looking at.",
				"/newcomm communityName - Create a new community.",
				"/delcomm - Delete Community.",
				"/leave - Leave a community.",
				"/invite playerName - Invite a player to the community.",
				"/remove playerName - Remove someone from the community.",
				"/accept - Accept community invite.",
				"/deny - Deny community invite.",
				"/setrank playerName rankInt - Change the rank of a player.",
				"/demoteself - Demote yourself in the community.",
				"/placestock - Place Community Stockpile.",
				"/remstock - Remove Community Stockpile.",
				"/placelocker - Place Community Locker.",
				"/remlocker - Remove Community Locker.",
				
				"Hands (Weapon):",
				"          Left Click - Gather Resources/Punch Player.",
				"          Right Click - Knock on Door.",
				"Keys (Weapon):",
				"          R or F12 - Take Ownership",
				"          R (After Ownership) - Open Ownership menu",
				"          Left Click - Unlock Door or Car.",
				"          Right Click - Lock Door or Car.",
				"Radio (Weapon)",
				"          When on, anyone on your frequancy can hear you talk. (Chat or Voice)",
				"          This is handy when Voice Limiter is on.",
				"          Left Click - Change Channel.",
				"          Right Click - Toggle Radio Power."
				}
				
				for k, v in pairs( helpCommands ) do
					local ReadThis = vgui.Create( "DLabel" )
						ReadThis:SetText( v )
						InGameComList:AddItem( ReadThis )
				end	
			pnlList:AddItem(InGameComDCats)
			
		local ClassDCats = vgui.Create("DCollapsibleCategory", pnlList)
			ClassDCats:SetSize( pnlList:GetWide()-50, 50 ) -- Keep the second number at 50
			ClassDCats:SetExpanded( 0 ) -- Expanded when popped up
			ClassDCats:SetLabel( "Classes" )
			 
			ClassList = vgui.Create( "DPanelList" )
			ClassList:SetAutoSize( true )
			ClassList:SetSpacing( 0 )
			ClassList:EnableHorizontal( false )
			ClassList:EnableVerticalScrollbar( true )
			 
			ClassDCats:SetContents( ClassList )
			
			local helpClass = 	{
			"Note: If enabled by admins, there is a cost to changing classes.",
			"The Class Menu can be accessed from the TAB Menu.",
			"",
			"WASTELANDER:",	
			"Bonus to HP",
			"Bonus to Endurance",
			"Radar HUD Tool",
			"",
			"SCAVENGER:",
			"Bonus to Run Speed",
			"Bonus to Gathering Speed",
			"Automated Sonic Miner",
			"",
			"ENGINEER:",	
			"Ability to create Weapons and Ammo",
			"Ability to create Vehicles",
			"Smelter (Able to convert Scrap/Small Parts)",
			"",
			"SCIENCE:",		
			"Ability to create Med Kits",
			"Ability to create Explosives",
			"Ability to create Turrets",
			"Ability to breed Wasteland Worms",
			"",
			"CULTIVATOR:",	
			"Ability to create higher quality food with additional bonuses",
			"Ability to cultivate plants"
			}
			
				for k, v in pairs( helpClass ) do
					local ReadThis = vgui.Create( "DLabel" )
						ReadThis:SetText( v )
						ClassList:AddItem( ReadThis )
				end	
			pnlList:AddItem(ClassDCats)
		
		local CommunityDCats = vgui.Create("DCollapsibleCategory", pnlList)
			CommunityDCats:SetSize( pnlList:GetWide()-50, 50 ) -- Keep the second number at 50
			CommunityDCats:SetExpanded( 0 ) -- Expanded when popped up
			CommunityDCats:SetLabel( "Communities" )
			 
			CommunityList = vgui.Create( "DPanelList" )
			CommunityList:SetAutoSize( true )
			CommunityList:SetSpacing( 0 )
			CommunityList:EnableHorizontal( false )
			CommunityList:EnableVerticalScrollbar( true )
			 
			CommunityDCats:SetContents( CommunityList )
			
			local helpCommunity = 	{
			"Communities help people band together and share resources and equipment.",
			"To open the Community Menu click the Community Menu button in the main menu.",
			"There are 3 levels in the community; Level 3 has full permissions, level 2 can invite, Level 1 is base membership.",
			"",
			"Community Stockpiles:",	
			"These allow communities to share resources. These can be broken into by other people.",
			"Anyone in the community can access this.",
			"",
			"Community Locker:",
			"This allows you to store items other than resources, this can also be broken into.",
			"",
			"All items in the Stockpile and Lockers are saved."
			}
			
				for k, v in pairs( helpCommunity ) do
					local ReadThis = vgui.Create( "DLabel" )
						ReadThis:SetText( v )
						CommunityList:AddItem( ReadThis )
				end	
			pnlList:AddItem(CommunityDCats)
		
		local SkillsDCats = vgui.Create("DCollapsibleCategory", pnlList)
			SkillsDCats:SetSize( pnlList:GetWide()-50, 50 ) -- Keep the second number at 50
			SkillsDCats:SetExpanded( 0 ) -- Expanded when popped up
			SkillsDCats:SetLabel( "Skills" )
			 
			SkillzList = vgui.Create( "DPanelList" )
			SkillzList:SetAutoSize( true )
			SkillzList:SetSpacing( 0 )
			SkillzList:EnableHorizontal( false )
			SkillzList:EnableVerticalScrollbar( true )
			 
			SkillsDCats:SetContents( SkillzList )
			
			local helpSkills = 	{
			"Skills are gained by spending experiance. Experiance is gained from killign mobs.",
			"",
			"Base Skills:",
			"Athletics - Increases run speed.",
			"Backpacking - Increases max inventory size.",
			"Salvaging - Higher yield from salvaging items.",	
			"Scavenging - Increases rate and success when scavenging.",
			"Weapon Handling - Increases accuracy and reduces recoil.",
			"",
			"Class Skills:",
			"Animal Husbandry (Science) - Increases the breeding success rate.",
			"Construction (Engineer) - Decreases cost for building items.",
			"Endurance (Wastelander) - Decreases rate of Endurance loss.",
			"Farming (Cultivator) - Changes the plants decay rate.",
			"Mining (Scavenger) - Increases the drop rate of the miner."
			}
			
				for k, v in pairs( helpSkills ) do
					local ReadThis = vgui.Create( "DLabel" )
						ReadThis:SetText( v )
						SkillzList:AddItem( ReadThis )
				end	
			pnlList:AddItem(SkillsDCats)
		
		local GatheringDCats = vgui.Create("DCollapsibleCategory", pnlList)
			GatheringDCats:SetSize( pnlList:GetWide()-50, 50 ) -- Keep the second number at 50
			GatheringDCats:SetExpanded( 0 ) -- Expanded when popped up
			GatheringDCats:SetLabel( "Gathering Resources" )
			 
			GatheringList = vgui.Create( "DPanelList" )
			GatheringList:SetAutoSize( true )
			GatheringList:SetSpacing( 0 )
			GatheringList:EnableHorizontal( false )
			GatheringList:EnableVerticalScrollbar( true )
			 
			GatheringDCats:SetContents( GatheringList )
			
			local helpGathering = 	{
			"Gathering is done by using your Hands and holding the Mouse 1 button while looking at the resource.",
			"Resources are scattered throughout the map.",
			"To trade resources, press TAB and select the Trade Menu button. The players must be within range to trade.",
			"There are 3 types of resources:",
			"Scrap:"
			}
			
				for k, v in pairs( helpGathering ) do
					local ReadThis = vgui.Create( "DLabel" )
						ReadThis:SetText( v )
						GatheringList:AddItem( ReadThis )
				end	
			
			local scraplList = vgui.Create("DPanelList", GatheringList)
			--	scraplList:SetPos(10, 10)
				scraplList:SetSize(pnlList:GetWide() - 20, 80)
				scraplList:EnableVerticalScrollbar(false) 
				scraplList:EnableHorizontal(true) 
				scraplList:SetSpacing(1)
				scraplList:SetPadding(5)	
				
				for k, v in pairs( PNRP.JunkModels ) do
					local scrapImage = vgui.Create("SpawnIcon", scraplList)
						scrapImage:SetModel( v )
						scrapImage:SetToolTip( nil )
						scraplList:AddItem( scrapImage )
				end	
				
				GatheringList:AddItem( scraplList )
			
			local smallPartsTextLbl = vgui.Create( "DLabel" )
				smallPartsTextLbl:SetText( "Small Parts:" )
				GatheringList:AddItem( smallPartsTextLbl )
				
			local smallPartsList = vgui.Create("DPanelList", GatheringList)
			--	smallPartsList:SetPos(10, 10)
				smallPartsList:SetSize(pnlList:GetWide() - 20, 80)
				smallPartsList:EnableVerticalScrollbar(false) 
				smallPartsList:EnableHorizontal(true) 
				smallPartsList:SetSpacing(1)
				smallPartsList:SetPadding(5)	
				
				for k, v in pairs( PNRP.SmallPartsModels ) do
					local smallPartsImage = vgui.Create("SpawnIcon", smallPartsList)
						smallPartsImage:SetModel( v )
						smallPartsImage:SetToolTip( nil )
						smallPartsList:AddItem( smallPartsImage )
				end	
				
				GatheringList:AddItem( smallPartsList )	
				
			local chemTextLbl = vgui.Create( "DLabel" )
				chemTextLbl:SetText( "Chemicals:" )
				GatheringList:AddItem( chemTextLbl )
				
			local chemList = vgui.Create("DPanelList", GatheringList)
			--	chemList:SetPos(10, 10)
				chemList:SetSize(pnlList:GetWide() - 20, 80)
				chemList:EnableVerticalScrollbar(false) 
				chemList:EnableHorizontal(true) 
				chemList:SetSpacing(1)
				chemList:SetPadding(5)	
				
				for k, v in pairs( PNRP.ChemicalModels ) do
					local chemImage = vgui.Create("SpawnIcon", chemList)
						chemImage:SetModel( v )
						chemImage:SetToolTip( nil )
						chemList:AddItem( chemImage )
				end	
				
				GatheringList:AddItem( chemList )		
			
		pnlList:AddItem(GatheringDCats)
			
		local OwnershipDCats = vgui.Create("DCollapsibleCategory", pnlList)
			OwnershipDCats:SetSize( pnlList:GetWide()-50, 50 ) -- Keep the second number at 50
			OwnershipDCats:SetExpanded( 0 ) -- Expanded when popped up
			OwnershipDCats:SetLabel( "Ownership" )
			 
			OwnershipList = vgui.Create( "DPanelList" )
			OwnershipList:SetAutoSize( true )
			OwnershipList:SetSpacing( 0 )
			OwnershipList:EnableHorizontal( false )
			OwnershipList:EnableVerticalScrollbar( true )
			 
			OwnershipDCats:SetContents( OwnershipList )
			
			local helpOwnership = 	{
			"Players are able to take ownership of most items within the game. Ownership is displayed at the top of the screen.",
			"",	
			"To take ownership of a item, use the F12 key while looking at that item.",
			"Players are not able to overide the ownership of another player and this system provides a level of protection",
			"for a players items. Turrets and Cars for example: other players are unable to weld or pickup these items if they are ",
			"owned by another player.",
			"",
			"Players are also able to lock doors and vehicles.",
			"Hands Tool - Alt+Mouse 1 = Unlock",
			"Hands Tool - Alt+Mouse 2 = Lock"
			}
			
				for k, v in pairs( helpOwnership ) do
					local ReadThis = vgui.Create( "DLabel" )
						ReadThis:SetText( v )
						OwnershipList:AddItem( ReadThis )
				end	
		pnlList:AddItem(OwnershipDCats)	
		
		local InvDCats = vgui.Create("DCollapsibleCategory", pnlList)
			InvDCats:SetSize( pnlList:GetWide()-50, 50 ) -- Keep the second number at 50
			InvDCats:SetExpanded( 0 ) -- Expanded when popped up
			InvDCats:SetLabel( "Inventory" )
			 
			InvList = vgui.Create( "DPanelList" )
			InvList:SetAutoSize( true )
			InvList:SetSpacing( 0 )
			InvList:EnableHorizontal( false )
			InvList:EnableVerticalScrollbar( true )
			 
			InvDCats:SetContents( InvList )
			
			local helpInv = 	{
			"A players inventory can be reached by pressing F3. If a player owns a car, the car inventory can be reached by",
			"looking at the car at close range and pressing F3.",	
			"To move items to the car inventory, just click the Send to Car Inv button.",
			"",
			"To drop an item, just click on the Icon for the item.",
			"To use the item from the inventory, just click the Use Item button.",
			"Items in your inventory can also be salvaged, at a reduced amount, by using the Salvage Item button.",
			"",
			"Keep in mind that items take up weight, and player/vehicle inventories are limited.",
			"Items in the vehicles tab do not take up weight."
			}
			
				for k, v in pairs( helpInv ) do
					local ReadThis = vgui.Create( "DLabel" )
						ReadThis:SetText( v )
						InvList:AddItem( ReadThis )
				end	
		pnlList:AddItem(InvDCats)
		
		local BuildDCats = vgui.Create("DCollapsibleCategory", pnlList)
			BuildDCats:SetSize( pnlList:GetWide()-50, 50 ) -- Keep the second number at 50
			BuildDCats:SetExpanded( 0 ) -- Expanded when popped up
			BuildDCats:SetLabel( "Building/Shop" )
			 
			BuildList = vgui.Create( "DPanelList" )
			BuildList:SetAutoSize( true )
			BuildList:SetSpacing( 0 )
			BuildList:EnableHorizontal( false )
			BuildList:EnableVerticalScrollbar( true )
			 
			BuildDCats:SetContents( BuildList )
			
			local helpBuild = 	{
			"To access the Shop menu, press the F4 key.",
			"To create items from the Shop menu you will need to have the correct Resources and will need to be the correct class.",
			"Some items in the Shop menu will require the player to have certin items in thier inventory to create another item.",
			"",
			"If the Prop Cost system is on, items from the Q menu will cost Scrap based on a calculation of the items mass and weight.",
			""
			}
			
				for k, v in pairs( helpBuild ) do
					local ReadThis = vgui.Create( "DLabel" )
						ReadThis:SetText( v )
						BuildList:AddItem( ReadThis )
				end	
		pnlList:AddItem(BuildDCats)	
		
		local HealthDCats = vgui.Create("DCollapsibleCategory", pnlList)
			HealthDCats:SetSize( pnlList:GetWide()-50, 50 ) -- Keep the second number at 50
			HealthDCats:SetExpanded( 0 ) -- Expanded when popped up
			HealthDCats:SetLabel( "Player Health/Death" )
			 
			HealthList = vgui.Create( "DPanelList" )
			HealthList:SetAutoSize( true )
			HealthList:SetSpacing( 0 )
			HealthList:EnableHorizontal( false )
			HealthList:EnableVerticalScrollbar( true )
			 
			HealthDCats:SetContents( HealthList )
			
			local helpHealth = 	{
			"Player Health:",
			"Players may recove HP in many ways.",
			"Get a Health Kit from a Scientist, Wait inside a building, or use /sleep when thier endurance is low enough.",
			"In order for a player to reciover health while asleep, they will need to be inside.",
			"",
			"Player Death:",
			"When you die, you will drop all your equiped weapons and ammo to the ground.",
			"This does not affect the items in your inventory.",
			"If enabled, there is a % cost to your resources when you die."
			}
			
				for k, v in pairs( helpHealth ) do
					local ReadThis = vgui.Create( "DLabel" )
						ReadThis:SetText( v )
						HealthList:AddItem( ReadThis )
				end	
		pnlList:AddItem(HealthDCats)	
		
		local EndHungerDCats = vgui.Create("DCollapsibleCategory", pnlList)
			EndHungerDCats:SetSize( pnlList:GetWide()-50, 50 ) -- Keep the second number at 50
			EndHungerDCats:SetExpanded( 0 ) -- Expanded when popped up
			EndHungerDCats:SetLabel( "Player Endurance/Hunger" )
			 
			EndHungerList = vgui.Create( "DPanelList" )
			EndHungerList:SetAutoSize( true )
			EndHungerList:SetSpacing( 0 )
			EndHungerList:EnableHorizontal( false )
			EndHungerList:EnableVerticalScrollbar( true )
			 
			EndHungerDCats:SetContents( EndHungerList )
			
			local helpEndHunger = 	{
			"Endurance:",
			"Players endurance decreases at a steady rate. To replenish your Endurance you can /sleep.",
			"To sleep, you must be inside and your endurance will need to be below 80%.",
			"Some foods will also replenish a small amount of endurnance.",
			"If your endurance reaches 0, you will pass out.",
			"",
			"Hunger:",
			"A players hunger decreases based on what the player is doing, if they are more active, it will decrease faster.",
			"Hunger is replenished by eating food.",
			"The Cultivator class is needed to create most types of food. Only the Can O Beans is available to all classes.",
			"If a players hunger reaches 0, they will start taking damage.",
			"",
			""
			}
			
				for k, v in pairs( helpEndHunger ) do
					local ReadThis = vgui.Create( "DLabel" )
						ReadThis:SetText( v )
						EndHungerList:AddItem( ReadThis )
				end	
		pnlList:AddItem(EndHungerDCats)
		
		local ToolDCats = vgui.Create("DCollapsibleCategory", pnlList)
			ToolDCats:SetSize( pnlList:GetWide()-50, 50 ) -- Keep the second number at 50
			ToolDCats:SetExpanded( 0 ) -- Expanded when popped up
			ToolDCats:SetLabel( "Player Tools" )
			 
			ToolList = vgui.Create( "DPanelList" )
			ToolList:SetAutoSize( true )
			ToolList:SetSpacing( 0 )
			ToolList:EnableHorizontal( false )
			ToolList:EnableVerticalScrollbar( true )
			 
			ToolDCats:SetContents( ToolList )
			
			local helpTool = 	{
			"Wastelander Radar:",
			"This tool can only be used by the Wastelander class. The tool must be placed outside in order to use. The Radar",
			"must be attached to the players HUD before the player can synch to it. This device can be dissabled by other",
			"players. Once activated the unit can not be moved.",
			"Ground-Penetrating Radar (GPR)",
			"Upgrade for the Wastelander Radar, just weld to the unit then sync the Radar",
			"",
			"Wasteland Worm:",
			"These worms will produce chemicals once every minute, and if the owner is a Scientist they have a 20% chance of",
			"breeding every 10 minutes. These grubs are fragil and must be taken care of.",
			"",
			"Potted Plant:",
			"The Potted Plant will produce oranges based on its condition. Only the cultivator knows how to take care of these",
			"and how to improve thier condition.",
			"",
			"Automated Sonic Miner:",
			"This can only be used by the Scavinger Class. This device will prodice 1 scrap or small part every minut. The miner",
			"will also fend off regular antlions as well. This device can also be dissabled.",
			"",
			"Smelting Furnace:",
			"This device is used by the Engineer to melt small parts into scrap.",
			"",
			"Pot, Pan, Skillet, and Coffee Pot:",
			"These are used by the Cultivator to make higher end food.",
			"",
			"Portable Turret:",
			"Can only be made by the Scientist, but can be used by any class.",
			""
			}
			
				for k, v in pairs( helpTool ) do
					local ReadThis = vgui.Create( "DLabel" )
						ReadThis:SetText( v )
						ToolList:AddItem( ReadThis )
				end	
		pnlList:AddItem(ToolDCats)
		
		local helpEnd = 	{
		"PostNukeRP Site: http://postnukerp.com/",
		"PostNukeRP Forums: http://gmdev.thercs.net/",
		"Radioactive Cricket Site: http://radioactivecricket.com/   (Will post updates here too)",
		"Checkout the MOTD for group information.",
		"",
		"You can also look for our PostNukeRP Steam group as well."
		}
		
		EndHelpList = vgui.Create( "DPanelList" )
		EndHelpList:SetAutoSize( true )
		EndHelpList:SetSpacing( 0 )
		EndHelpList:EnableHorizontal( false )
		EndHelpList:EnableVerticalScrollbar( true )
		 
		pnlList:AddItem(EndHelpList)
		
		for k, v in pairs( helpEnd ) do
			local ReadThis = vgui.Create( "DLabel" )
				ReadThis:SetText( v )
				ReadThis:SetTextColor(textColor)
				EndHelpList:AddItem( ReadThis )
		end	
		
		
end				

concommand.Add("pnrp_help", HelpPanel)

--EOF