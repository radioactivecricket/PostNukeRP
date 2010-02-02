
// Variables that are used on both client and server

SWEP.Author		= "Slob187 Edited by LostInTheWired"
SWEP.Contact		= "slob187.pb@gmail.com"
SWEP.Purpose		= "Hands."
SWEP.Instructions	= "Left click to punch and gather.\nRight click to knock the door."

SWEP.ViewModel		= "models/Weapons/V_hands.mdl"
SWEP.WorldModel		= "models/weapons/w_camphone.mdl"

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

    if (!SERVER) then return end
	
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

	if tr.Entity:IsJunkPile() then
        local data = {}
        data.Entity = tr.Entity

        data.Chance = 50
        data.MinAmount = 1
        data.MaxAmount = 3
		self.Owner:DoProcess("ScavScrap",2,data)
    end
	
	if tr.Entity:IsChemPile() then
        local data = {}
        data.Entity = tr.Entity

        data.Chance = 50
        data.MinAmount = 1
        data.MaxAmount = 3
		self.Owner:DoProcess("ScavChems",2,data)
    end
	
	if tr.Entity:IsSmallPile() then
        local data = {}
        data.Entity = tr.Entity

        data.Chance = 50
        data.MinAmount = 1
        data.MaxAmount = 3
		self.Owner:DoProcess("ScavParts",2,data)
    end
	
	if !tr.Entity:IsPlayer() then return end
	
	tr.Entity:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(1, 5)..".wav")
	tr.Entity:TakeDamage( 3, self.Owner , self.Weapon )
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
	
	if !string.find( string.lower( tr.Entity:GetClass() ), "door" ) then return end
	tr.Entity:EmitSound("physics/flesh/flesh_impact_bullet1.wav")
	self.NextKnock = CurTime() + .3
	
end

/*---------------------------------------------------------
	Think does nothing 
---------------------------------------------------------*/
function SWEP:Think()

end

