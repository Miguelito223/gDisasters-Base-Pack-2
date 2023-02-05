

if (SERVER) then
	
	local gDisasters_DamageTypes = {}

	
	gDisasters_DamageTypes["acid"] = function(ent)
		ParticleEffectAttach("acid_damage", PATTACH_POINT_FOLLOW, ent, 0)
	
	end
	
	gDisasters_DamageTypes["elemental"] = function(ent)
		ParticleEffectAttach("acid_damage", PATTACH_POINT_FOLLOW, ent, 0)
		ParticleEffectAttach("fire_damage", PATTACH_POINT_FOLLOW, ent, 0)
		ParticleEffectAttach("heat_damage", PATTACH_POINT_FOLLOW, ent, 0)
		ParticleEffectAttach("electrical_damage_01", PATTACH_POINT_FOLLOW, ent, 0)
		ParticleEffectAttach("cold_damage", PATTACH_POINT_FOLLOW, ent, 0)

	end
	
	gDisasters_DamageTypes["energy"] = function(ent)
		ParticleEffectAttach("fire_damage", PATTACH_POINT_FOLLOW, ent, 0)
		ParticleEffectAttach("heat_damage", PATTACH_POINT_FOLLOW, ent, 0)
		ParticleEffectAttach("electrical_damage_01", PATTACH_POINT_FOLLOW, ent, 0)

	end

	gDisasters_DamageTypes["fire"] = function(ent)
		ParticleEffectAttach("fire_damage", PATTACH_POINT_FOLLOW, ent, 0)
	
	end

	
	gDisasters_DamageTypes["heat"] = function(ent)

		ParticleEffectAttach("heat_damage", PATTACH_POINT_FOLLOW, ent, 0)

	
	end

	gDisasters_DamageTypes["electrical"] = function(ent)
		
		
		ParticleEffectAttach("electrical_damage_01", PATTACH_POINT_FOLLOW, ent, 0)
	
	
	end
	
	
	
	gDisasters_DamageTypes["cold"] = function(ent)
	
		ParticleEffectAttach("cold_damage", PATTACH_POINT_FOLLOW, ent, 0)
	
	end
	
	
	function InflictDamage(ent, attacker, dmgtype, amount)
	
		ent:TakeDamage( amount, attacker, attacker )
		gDisasters_DamageTypes[dmgtype](ent)
	
	end
	
	function InflictDamageInSphere(pos, radius, attacker, dmgtype, amount )
		
		for k, v in pairs(ents.FindInSphere(pos, radius)) do
			
			InflictDamage(v, attacker, dmgtype, amount)
		end
	
	end
	
end