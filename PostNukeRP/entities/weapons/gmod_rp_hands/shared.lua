
// Variables that are used on both client and server

SWEP.Author		= "Slob187 Edited by LostInTheWired"
SWEP.Contact		= "slob187.pb@gmail.com"
SWEP.Purpose		= "Hands."
SWEP.Instructions	= "Left click to punch and gather.\nRight click to knock the door."

SWEP.ViewModel		= "models/weapons/v_hands.mdl"
SWEP.WorldModel		= ""

SWEP.Spawnable      = false
SWEP.AdminSpawnable = false

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.NextPunch = 0
SWEP.NextKnock = 0


/*---------------------------------------------------------
	Initialize
---------------------------------------------------------*/
function SWEP:Initialize()

--    if (!SERVER) then return end
	
    self:SetWeaponHoldType("normal")	
						
end
	
/*---------------------------------------------------------
	Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

    if (!SERVER) then return end
    self.Owner:DrawWorldModel(false)
	
end	
	
	
/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
	
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
    
	if CurTime() < self.NextPunch then return end
	 
	local trace = {}
    trace.start = self.Owner:EyePos()
	trace.endpos = trace.start + self.Owner:GetAimVector() * 85
	trace.filter = self.Owner
	local tr = util.TraceLine(trace) 
	
	if (tr.HitWorld) then return end
	
    if (!SERVER) then return end		
	
    if !tr.Entity:IsValid() then return end
	if self.Owner:KeyDown(IN_WALK) then
		
	else
		-- if tr.Entity:IsJunkPile() then
			-- local data = {}
			-- data.Entity = tr.Entity

			-- data.Chance = 50
			-- data.MinAmount = 1
			-- data.MaxAmount = 3
			-- self.Owner:DoProcess("ScavScrap",2,data)
		-- end
		
		-- if tr.Entity:IsChemPile() then
			-- local data = {}
			-- data.Entity = tr.Entity

			-- data.Chance = 50
			-- data.MinAmount = 1
			-- data.MaxAmount = 3
			-- self.Owner:DoProcess("ScavChems",2,data)
		-- end
		
		-- if tr.Entity:IsSmallPile() then
			-- local data = {}
			-- data.Entity = tr.Entity

			-- data.Chance = 50
			-- data.MinAmount = 1
			-- data.MaxAmount = 3
			-- self.Owner:DoProcess("ScavParts",2,data)
		-- end
		
		if !tr.Entity:IsPlayer() then return end
		
		tr.Entity:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(1, 5)..".wav")
		tr.Entity:TakeDamage( 3, self.Owner , self.Weapon )
		
	end
	self.NextPunch = CurTime() + 1.5
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
    	
	local trace = {}
    trace.start = self.Owner:EyePos()
	trace.endpos = trace.start + self.Owner:GetAimVector() * 85
	trace.filter = self.Owner
	local tr = util.TraceLine(trace) 		
		
	if CurTime() < self.NextKnock then return end
	
    if (!SERVER) then return end	
	
	if !tr.Entity:IsValid() then return end
	if self.Owner:KeyDown(IN_WALK) then
		-- local owner = tr.Entity:GetNWString( "Owner", "None" )
		-- if tr.Entity:IsDoor() and self.Owner:Nick() == owner then
			-- tr.Entity:EmitSound(Sound("doors/latchlocked2.wav"))
			-- self.Owner:ChatPrint("Locked.")
			-- tr.Entity:Fire("Lock", "", 0)
		-- elseif tr.Entity:IsVehicle() and self.Owner:Nick() == owner then
			-- tr.Entity:EmitSound(Sound("doors/latchlocked2.wav"))
			-- self.Owner:ChatPrint("Locked.")
			-- tr.Entity:Fire("Lock", "", 0)
		-- end
	else
		if !string.find( string.lower( tr.Entity:GetClass() ), "door" ) then return end
		tr.Entity:EmitSound("physics/flesh/flesh_impact_bullet1.wav")
		
	end
	self.NextKnock = CurTime() + .3
end

function SWEP:Reload()
	local trace = {}
    trace.start = self.Owner:EyePos()
	trace.endpos = trace.start + self.Owner:GetAimVector() * 100
	trace.filter = self.Owner
	local tr = util.TraceLine(trace) 
	
	if (!SERVER) then return end
	
	if !tr.Entity:IsValid() then return end
	
	local owner = tr.Entity:GetNWString( "Owner", "None" )
	
	-- if tr.Entity:IsDoor() and self.Owner:Nick() == owner then
		-- if todo == "unlock" then
			-- tr.Entity:EmitSound(Sound("doors/latchunlocked1.wav"))
			-- self.Owner:ChatPrint("Unlocked.")
		-- elseif todo == "Lock" then
			-- tr.Entity:EmitSound(Sound("doors/latchlocked2.wav"))
			-- self.Owner:ChatPrint("Locked.")
		-- end
		-- tr.Entity:Fire(todo, "", 0)
	-- end
	
	-- if tr.Entity:IsVehicle() and self.Owner:Nick() == owner then
		-- for k, v in pairs(tr.Entity:GetKeyValues()) do
			-- self.Owner:ChatPrint(k.." = "..tostring(v))
			-- if (k == "Lock") then
				-- if v == 1 then
					-- todo="Lock"
				-- end
			-- elseif (k == "Unlock") then
				-- if v == 1 then
					-- todo="unlock"
				-- end
			-- end

		-- end
		-- if todo == "unlock" then
			-- tr.Entity:EmitSound(Sound("doors/latchunlocked1.wav"))
			-- self.Owner:ChatPrint("Unlocked.")
		-- elseif todo == "Lock" then
			-- tr.Entity:EmitSound(Sound("doors/latchlocked2.wav"))
			-- self.Owner:ChatPrint("Locked.")
		-- end
		-- tr.Entity:Fire(todo, "", 0)
	-- end
	
end

/*---------------------------------------------------------
	Think does nothing 
---------------------------------------------------------*/
function SWEP:Think()

end

