AddCSLuaFile()

ENT.Type            = "anim"

if SERVER then
	function ENT:Initialize()
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )

		local PhysObj = self:GetPhysicsObject()

		if not IsValid( PhysObj ) then return end

		PhysObj:SetMass( 1 )
		PhysObj:EnableMotion( false )

		self:PrecacheGibs()
	end

	function ENT:Think()
		return false
	end

	local CustomGibs = {
		["models/exor/physic/storeshelflargecluster.mdl"] = {
			["placementOrigin01"] = "models/exor/physic/storeshelfbags.mdl",
			["placementOrigin02"] = "models/exor/physic/storeshelfcontainers.mdl",
			["placementOrigin03"] = "models/exor/physic/storeshelfbottles.mdl",
			["placementOrigin04"] = "models/exor/physic/storeshelfbags.mdl",
			["placementOrigin05"] = "models/exor/physic/storeshelfbags.mdl",
			["placementOrigin06"] = "models/exor/physic/storeshelfbottles.mdl",
		},
		["models/exor/physic/storeshelflargedoublecluster.mdl"] = {
			["placementOrigin01"] = "models/exor/physic/storeshelfcontainers.mdl",
			["placementOrigin02"] = "models/exor/physic/storeshelfcontainers.mdl",
			["placementOrigin03"] = "models/exor/physic/storeshelfcontainers.mdl",
			["placementOrigin04"] = "models/exor/physic/storeshelfcontainers.mdl",
			["placementOrigin05"] = "models/exor/physic/storeshelfbottles.mdl",
			["placementOrigin06"] = "models/exor/physic/storeshelfbottles.mdl",
			["placementOrigin07"] = "models/exor/physic/storeshelfbottles.mdl",
			["placementOrigin08"] = "models/exor/physic/storeshelfbottles.mdl",
			["placementOrigin09"] = "models/exor/physic/storeshelfbottles.mdl",
			["placementOrigin10"] = "models/exor/physic/storeshelfbags.mdl",
			["placementOrigin11"] = "models/exor/physic/storeshelfbags.mdl",
		}
	}

	function ENT:MakeGibs( velocity )
		local MDL = self:GetModel()

		if not CustomGibs[ MDL ] then self:GibBreakClient( velocity ) return end

		for attachmentName, model in pairs( CustomGibs[ MDL ] ) do
			local attachment = self:GetAttachment( self:LookupAttachment( attachmentName ) )

			if not attachment then continue end

			local Ang = attachment.Ang
			Ang:RotateAroundAxis( self:GetUp(), -90 )

			local prop = ents.Create("prop_physics_diprip")
			prop:SetModel( model )
			prop:SetPos( attachment.Pos )
			prop:SetAngles( Ang )
			prop:Spawn()
			prop:Activate()

			local PhysObj = prop:GetPhysicsObject()

			if not IsValid( PhysObj ) then continue end

			PhysObj:SetMass( 1 )
			PhysObj:EnableMotion( true )
			PhysObj:Wake()
		end
	end

	function ENT:PhysicsCollide( data, physobj )
		if self._DontCallAgain then return end

		if not IsValid( data.HitEntity ) then return end

		self:MakeGibs( data.TheirOldVelocity )

		local Vel = data.TheirOldVelocity
		local AngVel = data.TheirOldAngularVelocity

		local PhysObj = data.HitEntity:GetPhysicsObject()

		if not IsValid( PhysObj ) or data.HitEntity:GetCollisionGroup() == COLLISION_GROUP_DEBRIS then return end

		local Vel = data.TheirOldVelocity
		local AngVel = data.TheirOldAngularVelocity

		PhysObj:SetVelocityInstantaneous( Vel )
		PhysObj:SetAngleVelocityInstantaneous( AngVel )

		timer.Simple( 0, function()
			if not IsValid( PhysObj ) then return end

			PhysObj:SetVelocityInstantaneous( Vel )
			PhysObj:SetAngleVelocityInstantaneous( AngVel )
		end )

		self:SetNoDraw( true )

		physobj:EnableMotion( true )
		physobj:Wake()

		SafeRemoveEntityDelayed( self, 0 )

		self._DontCallAgain = true
	end

	function ENT:OnTakeDamage( dmginfo )
		if not dmginfo:IsDamageType( DMG_BLAST ) then return end

		self:MakeGibs( dmginfo:GetDamageForce() )
		SafeRemoveEntityDelayed( self, 0 )

		self._DontCallAgain = true
	end

	local SoundList = {
		["models/exor/physic/lamp.mdl"] = "Diprip_Lamp.Break",
		["models/exor/physic/lampsmall.mdl"] = "Diprip_Lamp.Break",
		["models/exor/physic/treedeciduouslivingmediumphys.mdl"] = "Diprip_Tree.Break",
		["models/exor/physic/treedeciduousdyingmediumphys.mdl"] = "Diprip_Tree.Break",
		["models/exor/physic/treedeciduousdyingsmallphys.mdl"] = "Diprip_Tree.Break",
		["models/exor/physic/plotbudowlany.mdl"] = "Diprip_Tree.Break",
		["models/exor/physic/storeshelfbags.mdl"] = "Metal_Box.Break",
		["models/exor/physic/storeshelfbottles.mdl"] = "Metal_Box.Break",
		["models/exor/physic/storeshelfcontainers.mdl"] = "Metal_Box.Break",
		["models/exor/physic/storeshelflargedoublecluster.mdl"] = "Diprip_Kiosk.Break",
		["models/exor/physic/storeshelflargecluster.mdl"] = "Diprip_Kiosk.Break",
		["models/exor/physic/budkatelefoniczna.mdl"] = "Glass.Break",
		["models/exor/physic/shopwindowlarge.mdl"] = "Glass.Break",
		["models/exor/physic/shopwindowlarge1.mdl"] = "Glass.Break",
		["models/exor/physic/shopwindowlarge2.mdl"] = "Glass.Break",
		["models/exor/physic/shopwindowlarge3.mdl"] = "Glass.Break",
		["models/exor/physic/shopdoorslarge.mdl"] = "Glass.Break",
		["models/exor/physic/lawkaosiedlowa.mdl"] = "Wood.Break",
		["models/exor/physic/metal_barrier.mdl"] = "Metal_Box.ImpactHard",
		["models/exor/physic/gasstationdistributor.mdl"] = "Metal_Box.Break",
		["models/exor/physic/smallmetalkiosk.mdl"] = "Diprip_Kiosk.Break",
		["models/exor/physic/metal_fence_main01.mdl"] = "Wood.Break",
		["models/exor/physic/metal_fence_main02.mdl"] = "Wood.Break",
		["models/exor/physic/metal_fence_main03.mdl"] = "Wood.Break",
		["models/exor/physic/metal_fence_main04.mdl"] = "Wood.Break",
		["models/exor/physic/barrier.mdl"] = "Wood.Break",
		["models/exor/physic/znakhydrant.mdl"] = "Wood.Break",
		["models/exor/physic/petrolstationpillar.mdl"] = "Boulder.ImpactHard",
		["models/props_wasteland/cafeteria_table001a.mdl"] = "Wood.Break",
		["models/exor/physic/tram_pylon.mdl"] = "Metal_Box.Break",
		["models/exor/physic/traffic_light_big.mdl"] = "Metal_Box.Break",
		["models/exor/physic/snopkisiana01.mdl"] = "Diprip_Hay.Break",
		["models/exor/physic/snopkisiana02.mdl"] = "Diprip_Hay.Break",
		["models/exor/physic/constructionyard_woodendetail.mdl"] = "Diprip_Tree.Break",
		["models/exor/physic/sluptelegraficzny_ref.mdl"] = "Diprip_Tree.Break",
		["models/exor/physic/plotdrewnianywies.mdl"] = "Diprip_Tree.Break",
		["models/exor/physic/plotdrewnianywieszlamany.mdl"] = "Diprip_Tree.Break",
		["models/exor/physic/karuzela.mdl"] = "Wood.Break",
	}

	function ENT:OnRemove()
		if not self._DontCallAgain then return end

		local MDL = self:GetModel()

		if not SoundList[ MDL ] then return end

		local Pos1 = self:GetPos()
		local Pos2 = self:LocalToWorld( self:OBBCenter() )
	
		if util.IsInWorld( Pos1 ) then
			EmitSound( SoundList[ MDL ], Pos1 )

			return
		end

		EmitSound( SoundList[ MDL ], Pos2 )
	end

	local MAPDATA = {
		["de_dam"] = true,
		["dm_city"] = true,
		["dm_dam"] = true,
		["dm_refinery"] = true,
		["dm_supermarket"] = true,
		["dm_village"] = true,
		["ur_city"] = true,
		["ur_refinery"] = true,
		["ur_supermarket"] = true,
		["ur_village"] = true,
	}

	local function ReplaceProps()
		local mapdata = MAPDATA[ game.GetMap() ]

		if not mapdata then return end

		for id, ent in pairs( ents.FindByClass("prop_physics") ) do
			local newEnt = ents.Create("prop_physics_diprip")
			newEnt:SetModel( ent:GetModel() )
			newEnt:SetPos( ent:GetPos() )
			newEnt:SetAngles( ent:GetAngles() )
			newEnt:Spawn()
			newEnt:Activate()

			ent:Remove()
		end
	end

	hook.Add( "InitPostEntity", "diprip_mapmodifications", function()
		ReplaceProps()
	end )

	hook.Add( "PostCleanupMap", "diprip_mapmodifications", function()
		ReplaceProps()
	end )
else
	function ENT:Draw( flags )
		self:DrawModel( flags )
	end

	function ENT:OnRemove()
	end
end
