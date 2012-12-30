include("shared.lua")

language.Add("ent_testcharge", "Shaped Charge")

/*---------------------------------------------------------
   Name: ENT:Draw()
---------------------------------------------------------*/
function ENT:Draw()

	self.Entity:DrawModel()
end