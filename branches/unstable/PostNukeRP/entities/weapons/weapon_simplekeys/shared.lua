SWEP.Author		= "LostInTheWired"
SWEP.Contact		= "lostinthewired@gmail.com"
SWEP.Purpose		= "Keys for SimpleKeys"
SWEP.Instructions	= "Left click to unlock.\nRight click to lock.\nR to enter door management or ownership."

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

SWEP.NextLeft = 0
SWEP.NextRight = 0
SWEP.NextR = 0


---------------------------------------------------------
--	Initialize
---------------------------------------------------------
function SWEP:Initialize()

--    if (!SERVER) then return end
	
    self:SetWeaponHoldType("normal")	
						
end
	
---------------------------------------------------------
--	Deploy
---------------------------------------------------------
function SWEP:Deploy()

    if (!SERVER) then return end
    self.Owner:DrawWorldModel(false)
	
end	

---------------------------------------------------------
--	Reload
---------------------------------------------------------
function SWEP:Reload()
	if CurTime() < self.NextR then return end
	if (!SERVER) then return end
	
	local trace = {}
    trace.start = self.Owner:EyePos()
	trace.endpos = trace.start + self.Owner:GetAimVector() * 85
	trace.filter = self.Owner
	local tr = util.TraceLine(trace)
	
	local doorEnt = tr.Entity
	
	if (tr.HitWorld) then return end
	if !tr.Entity:IsValid() then return end
	if not (tr.Entity:IsDoor() or tr.Entity:IsVehicle()) then return end
	
	local doorowner = doorEnt:GetNWEntity( "ownerent", nil )
	if !doorowner:IsValid() then
		self.Owner:ConCommand("pnrp_setOwner")
		-- self.Owner:ChatPrint("You have taken ownership of this door!")
	elseif doorowner == self.Owner then
		--Open Door Management
		--datastream.StreamToClients(self.Owner, "manageDoor", { ["doorEnt"] = doorEnt, ["coowners"] = doorEnt.Coowners })
		net.Start("manageDoor")
			net.WriteEntity(doorEnt)
			net.WriteTable(doorEnt.Coowners or {})
		net.Send(self.Owner)
	else
		self.Owner:ChatPrint("You don't have this key.")
	end
	
	self.NextR = CurTime() + 1
end

---------------------------------------------------------
--	PrimaryAttack
---------------------------------------------------------
function SWEP:PrimaryAttack()
	if CurTime() < self.NextLeft then return end
	if (!SERVER) then return end
	
	local trace = {}
    trace.start = self.Owner:EyePos()
	trace.endpos = trace.start + self.Owner:GetAimVector() * 85
	trace.filter = self.Owner
	local tr = util.TraceLine(trace)
	
	if (tr.HitWorld) then return end
	if !tr.Entity:IsValid() then return end
	if not (tr.Entity:IsDoor() or tr.Entity:IsVehicle()) then return end
	
	local doorEnt = tr.Entity
	if self.Owner:SKIsOwner( doorEnt ) or self.Owner:SKIsCoowner( doorEnt ) then
		doorEnt:EmitSound(Sound("doors/latchunlocked1.wav"))
		self.Owner:ChatPrint("Unlocked.")
		doorEnt:Fire("unlock", "", 0)
	else
		self.Owner:ChatPrint("You don't have this key.")
	end
	
	self.NextLeft = CurTime() + 1
end

---------------------------------------------------------
--	SecondaryAttack
---------------------------------------------------------
function SWEP:SecondaryAttack()
	if CurTime() < self.NextRight then return end
	if (!SERVER) then return end
	
	local trace = {}
    trace.start = self.Owner:EyePos()
	trace.endpos = trace.start + self.Owner:GetAimVector() * 85
	trace.filter = self.Owner
	local tr = util.TraceLine(trace)
	
	if (tr.HitWorld) then return end
	if !tr.Entity:IsValid() then return end
	if not (tr.Entity:IsDoor() or tr.Entity:IsVehicle()) then return end
	
	local doorEnt = tr.Entity
	if self.Owner:SKIsOwner( doorEnt ) or self.Owner:SKIsCoowner( doorEnt ) then
		doorEnt:EmitSound(Sound("doors/latchlocked2.wav"))
		self.Owner:ChatPrint("Locked.")
		doorEnt:Fire("Lock", "", 0)
	else
		self.Owner:ChatPrint("You don't have this key.")
	end
	
	self.NextRight = CurTime() + 1
end
