-----------------------
-- NO: A game of numbers
-- Created: 23.08.08 by Michael Enger
-- Version: 0.2
-- Website: http://www.facemeandscream.com
-- Licence: ZLIB
-----------------------
-- Handles buttons and such.
-----------------------

Shock = {}
Shock.__index = Shock

function Shock.create(blockhouse)
	
 local temp = {}
	setmetatable(temp, Shock)
	temp.name = "Shock"
	temp.target = nil
	temp.shoot_time = 0
	temp.blockhouse  = blockhouse

	return temp
	
end
function Shock:reloadGun()
	self.shoot_time  = love.timer.getMicroTime( )
end
function Shock:getReloadTime()
	local weapon = self.blockhouse.weapon
    local level = self.blockhouse.level
	local shoot_time = tower_upgrade[weapon][level].shoot_time
	
	if (love.timer.getMicroTime( ) - self.shoot_time  > shoot_time) then
		return 0
	else
		return shoot_time - (love.timer.getMicroTime( ) - self.shoot_time)
	end
end
function Shock:isReadyShoot()
	local weapon = self.blockhouse.weapon
    local level = self.blockhouse.level
	local shoot_time = tower_upgrade[weapon][level].shoot_time
	return (love.timer.getMicroTime( ) - self.shoot_time  > shoot_time)
end
function Shock:update(dt)

    local weapon = self.blockhouse.weapon
    local level = self.blockhouse.level 
	local range = tower_upgrade[weapon][level].range*7
	 
	 
	if (self.target == nil) then --获取一个target
		local lastwanttarget = nil
		for i,e in pairs(state.enemys) do

			if(e.hidden~=true and math.abs(e.x - self.blockhouse.x) <= range and math.abs(e.y - self.blockhouse.y) <= range) then
			    if(lastwanttarget == nil) then
			    	lastwanttarget = e
			    end
			    if(e.slowly == false) then
					self.target = e
			    	e.locked = e.locked + 1
			    	break
			    end
			end
		end
		if (self.target == nil and lastwanttarget ~= nil) then
			self.target = lastwanttarget
			lastwanttarget.locked = lastwanttarget.locked + 1
		end
	else
        if(self.target.health <=0 or self.target.slowly == true) then -- 跟踪的目标被击毙了或者中了减速弹 
			self.target = nil
		else
			local dx = self.target.x - self.blockhouse.x
			local dy = self.target.y - self.blockhouse.y
			local angle = (math.atan2(dy, dx)*180/math.pi)%360
			if( self.blockhouse.angle > angle ) then
				self.blockhouse.angle =  (self.blockhouse.angle - 90*dt*5) % 360  
			else
				self.blockhouse.angle =  (self.blockhouse.angle + 90*dt*5) % 360  
			end
			if(self:isReadyShoot() and math.abs(self.blockhouse.angle - angle)<5 ) then -- 发射子弹
				love.audio.play(sound["slowdown_fire"])
				self:reloadGun()
				table.insert(state.ballets , Ballet.create(3, self,self.blockhouse.x ,self.blockhouse.y ,self.target))
			end


			local e = self.target
			if(math.abs(e.x - self.blockhouse.x) > range or math.abs(e.y - self.blockhouse.y) > range) then
				self.target = nil
				e.locked = e.locked - 1
			end
		end


	end

end
