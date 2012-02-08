function Ammo_reloadGun(ammo_instance)
	ammo_instance.shoot_time  = love.timer.getMicroTime( )
end
function Ammo_getReloadTime(ammo_instance)
	local weapon = ammo_instance.blockhouse.weapon
    local level = ammo_instance.blockhouse.level
	local shoot_time = tower_upgrade[weapon][level].shoot_time
	
	if (love.timer.getMicroTime( ) - ammo_instance.shoot_time  > shoot_time) then
		return 0
	else
		return shoot_time - (love.timer.getMicroTime( ) - ammo_instance.shoot_time)
	end
end
function Ammo_isReadyShoot(ammo_instance)
	local weapon = ammo_instance.blockhouse.weapon
    local level = ammo_instance.blockhouse.level
	local shoot_time = tower_upgrade[weapon][level].shoot_time
	return (love.timer.getMicroTime( ) - shoot_time  > shoot_time)
end 
