include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
	
	AddWorldTip( self.Entity:EntIndex(), tostring(self.Entity:GetNWString("distance")), 0.5, self.Entity:GetPos(), self.Entity )
end
