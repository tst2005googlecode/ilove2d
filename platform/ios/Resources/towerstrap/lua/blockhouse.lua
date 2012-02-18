-----------------------
-- NO: A game of numbers
-- Created: 23.08.08 by Michael Enger
-- Version: 0.2
-- Website: http://www.facemeandscream.com
-- Licence: ZLIB
-----------------------
-- Handles buttons and such.
-----------------------

Blockhouse = {}
Blockhouse.__index = Blockhouse

function Blockhouse.create(weapon,grid_col,grid_row)
	lastselected = nil
	local temp = {}
	setmetatable(temp, Blockhouse)
	temp.hover = false -- whether the mouse is hovering over the button
	temp.hover_up = false
	temp.hover_down = false
	temp.click = false -- whether the mouse has been clicked on the button
	temp.weapon = weapon -- the text in the button
	temp.level = 1
	temp.fireangle = 0
	temp.sniffereangle = 0
	temp.buildangle = 0
	temp.ice = false
	temp.ice_time = 0
	temp.live = 1
	if(weapon == 1) then -- sniper
	    temp.gun = Sniper.create(temp)
 	elseif(weapon == 2) then -- rocket
	    temp.gun = Rocket.create(temp)
	elseif(weapon ==3) then --cannon
	    temp.gun = Cannon.create(temp)
	elseif(weapon ==4) then --shock
	    temp.gun = Shock.create(temp)
	elseif(weapon == 5) then -- air
		temp.gun = Air.create(temp)
	elseif(weapon == 6) then -- earthquake
	    temp.gun = EarthQuake.create(temp)
	elseif(weapon == 7) then -- radar
	    temp.gun = Radar.create(temp)
	end
	if(weapon == 5) then -- air
		temp.buildangle = 720
		temp.angle = 0
	else
		temp.angle = math.random(0,360)
	end
	
	if(weapon == 6) then -- earthquacke
	    temp.earthquake_action_r = 6
	else
	    temp.earthquake_action_r = 0
	end
	
    temp.grid_col = grid_col
    temp.grid_row = grid_row
	temp.width = graphics["blockhous"][weapon]:getWidth()
	temp.height = graphics["blockhous"][weapon]:getHeight()
	temp.x = battlearea.left + grid_col * GRID_SIZE
	temp.y = battlearea.top + grid_row * GRID_SIZE
	temp.centX = temp.x + GRID_SIZE
	temp.centY = temp.y + GRID_SIZE
	 

	--pr(temp.gun,"create blockhouse")
	return temp
	
end

function Blockhouse:draw()
	local i = self.weapon
	 
	local cxoffset = 0;
	if(i == 1) then
		cxoffset = -2
	end
	love.graphics.draw(graphics["blockhous"][i], self.centX , self.centY, angleToradians(self.angle),  1, 1, self.width/2 + cxoffset, self.height/2)
	
	if self.ice then
	    love.graphics.setColor(255,255,255,200)
     	love.graphics.rectangle( "fill", self.x ,self.y  ,graphics["bh_border_ice"]:getWidth(),graphics["bh_border_ice"]:getHeight())
     	love.graphics.draw(graphics["bh_border_ice"],self.centX,self.centY, 0,  1, 1, graphics["bh_border_ice"]:getWidth()/2 , graphics["bh_border_ice"]:getHeight()/2)
	else
		love.graphics.draw(graphics["bh_border"],self.centX,self.centY, 0,  1, 1, graphics["bh_border"]:getWidth()/2, graphics["bh_border"]:getHeight()/2)
	end

	
	if (self.weapon == 6) and self.earthquake_action_r>0 then
		love.graphics.setColor(color["shadow"])
		love.graphics.circle( "fill", self.centX, self.centY, self.earthquake_action_r*7,255 )
	end
	

	local s = ""
	local h = ""
	if(self.hover) then
	h = "hover"
	else
	h = "leave"
	end
	if(self.selected) then
	s = "selected"
	else
	s ="unsel"
	end


	-- ª≠µÔ±§–≈œ¢ 
	if self.hover and debug  then
		love.graphics.setFont(font["tiny"])
 		love.graphics.setColor(color["text"])
		love.graphics.print(string.format("angle=%d,gun=%s,gun.shoot_time=%d,x=%d,y=%d,w=%d,h=%d,s=%s,m=%s",self.angle,self.gun.name,self.gun:getReloadTime(),self.centX,self.centY,self.width,self.height,s,h),self.centX,self.centY)
	end

end
function Blockhouse:drawselector()

        local weapon = self.weapon
    	local level = self.level
		local range = tower_upgrade[weapon][level].range*7
		love.graphics.setColor(color["green_ol"])

		love.graphics.circle( "fill", self.centX, self.centY, range,255 )

		-- draw upgrade rectangle
		love.graphics.setLine( 1 )
		love.graphics.setColor(color["gray"])

		local textheight = font["tiny"]:getHeight()

		if(self.level < 5) then
			love.graphics.rectangle( "fill", self.x, self.y - GRID_SIZE, GRID_SIZE*2, GRID_SIZE)
			love.graphics.setColor(255,155,0)
			love.graphics.rectangle( "line", self.x+ 1, self.y + 1 - GRID_SIZE, GRID_SIZE*2 - 2, GRID_SIZE - 2)

			local buy_cost = tower_upgrade[self.weapon][self.level +1 ].buy_cost
			love.graphics.setColor(color["yellow"])
			love.graphics.setFont(font["tiny"])
			local textwidth = font["tiny"]:getWidth(buy_cost)
			love.graphics.print( buy_cost, self.centX - textwidth /2, self.y - GRID_SIZE / 2 )
		end

		local sell_cost = tower_upgrade[self.weapon][self.level].sell_cost
		love.graphics.setColor(255,85,32)
		love.graphics.rectangle( "fill", self.x, self.y + GRID_SIZE*2, GRID_SIZE*2, GRID_SIZE)
		love.graphics.setColor(color["yellow"])
		love.graphics.setFont(font["tiny"])
		local textwidth = font["tiny"]:getWidth(sell_cost)
		love.graphics.print( sell_cost, self.centX - textwidth /2, self.y + GRID_SIZE*2 + GRID_SIZE  - GRID_SIZE /2 )


end
function Blockhouse:update(dt)
	dt = dt
	--print("dt"..dt)
	if(self.ice_time>0) then
	    self.ice_time = self.ice_time - dt
	else
	    self.ice = false
	end

	self.hover = false
	self.hover_up = false
	self.hover_down = false
	local x = love.mouse.getX()
	local y = love.mouse.getY()
	
	if x > self.x
		and x < self.x + self.width
		and y > self.y
		and y < self.y + self.height then
		self.hover = true
	elseif x > self.x
	    and x < self.x + self.width
	    and y > self.y - GRID_SIZE
	    and y < self.y - 2 then
	    self.hover_up = true
	elseif x > self.x
	    and x < self.x + self.width
	    and y > self.y + self.height
	    and y < self.y + self.height + GRID_SIZE then
	    self.hover_down = true
	end
	--print("buildangle:" .. self.buildangle)
	if(self.buildangle > 0 ) then
   		self.buildangle = self.buildangle - 720 / (love.timer.getFPS() * 0.3)
		if(math.abs(self.angle - self.buildangle) > 15) then
   		self.angle = self.buildangle
		end
		 
   	elseif(self.fireangle > 0) then
		self.fireangle = self.fireangle - 720 / (love.timer.getFPS() * 0.3)
   		self.angle = self.fireangle 
		
	elseif(self.sniffereangle>0 )then
		print("self.sniffereangle" .. self.sniffereangle)
     	self.sniffereangle = self.sniffereangle - 360 / (love.timer.getFPS() * 0.9)
   		self.angle = self.sniffereangle
	end
	
   	if(self.ice) then
		return
	end


	if(self.earthquake_action_r > 0) then
	    self.earthquake_action_r = self.earthquake_action_r - 1.2*love.timer.getFPS()* dt
	end


	if(self.gun ~=nil) then
		self.gun:update(dt)
	end
	
end

function Blockhouse:mousepressed(x, y, button)
 	local weapon = self.weapon
	local level = self.level
	if self.hover then
		if audio then
			love.audio.play(sound["click"])
		end
		state.gselectedBlockhouse = self
        state.weapons:unSelected()
	elseif state.gselectedBlockhouse == self and self.hover_up and level < 5 then --upgrade
		local buy_cost = tower_upgrade[weapon][level+1].buy_cost
		if state.money > buy_cost then
			self.level = self.level + 1
			state.money = state.money - buy_cost
		end
		return false
	elseif state.gselectedBlockhouse == self and self.hover_down then --sell
	    state.money = state.money + tower_upgrade[weapon][level].sell_cost
	    self.live = 0
	    state.gselectedBlockhouse = nil
     	return false
	end
	return true
	
end
