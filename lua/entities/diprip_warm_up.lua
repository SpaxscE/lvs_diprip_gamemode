AddCSLuaFile()

ENT.Type            = "anim"

if SERVER then
	function ENT:Initialize()
		self:Remove()
	end

	function ENT:Think()
		return false
	end

	function ENT:PhysicsCollide( data, physobj )
	end

	function ENT:OnTakeDamage( dmginfo )
	end

	function ENT:OnRemove()
	end
else
	function ENT:Draw( flags )
	end

	function ENT:OnRemove()
	end
end
