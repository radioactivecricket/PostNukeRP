SWEP.Author		= "LostInTheWired"
SWEP.Contact		= "lostinthewired@gmail.com"
SWEP.Purpose		= "Keys for SimpleKeys"
SWEP.Instructions	= "Just your hands or keys.\nLeft click to unlock.\nRight click to lock.\nR to enter door management or ownership."

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
	
	local ent = tr.Entity
	
	local adminOveride = false
	if self.Owner:IsAdmin() and getServerSetting("adminTouchAll") == 1 then adminOveride = true end
	
	if (tr.HitWorld) then return end
	if !ent:IsValid() then return end
	
	local item = PNRP.SearchItembase( ent )
	local useKeys = false
	if item then 
		if self.Owner:KeyDown( IN_WALK ) and item.Keys then
			useKeys = true
		elseif item.CanRepair then 
			if table.getn(item.RepairClass) == 0 or adminOveride then
				net.Start("repairMenu")
					net.WriteEntity(ent)
				net.Send(self.Owner)
			elseif inTable(item.RepairClass, self.Owner:Team()) then
				net.Start("repairMenu")
					net.WriteEntity(ent)
				net.Send(self.Owner)
			else
				local teamString = ""
				for v, teamNum in pairs(item.RepairClass) do
					teamString = teamString.." "..team.GetName(teamNum)
					if v < table.getn(item.RepairClass) then teamString = teamString.."," end
				end
				self.Owner:ChatPrint("You must be one the following class to fix this:"..teamString)
			end
			
			self.NextR = CurTime() + 1
			return
		end
	end
	
	if not (ent:IsDoor() or useKeys) then return end
	
	local doorowner = ent:GetNetVar( "ownerent", nil )
	if doorowner == nil then return end
	if !doorowner:IsValid() then
		self.Owner:ConCommand("pnrp_setOwner")
	elseif doorowner == self.Owner then
		--Open Door Management
		net.Start("manageDoor")
			net.WriteEntity(ent)
			net.WriteTable(ent.Coowners or {})
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
