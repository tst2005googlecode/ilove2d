-----------------------
-- NO: A game of numbers
-- Created: 23.08.08 by Michael Enger
-- Version: 0.2
-- Website: http://www.facemeandscream.com
-- Licence: ZLIB
-----------------------
-- Handles buttons and such.
-----------------------
--require("vardump.lua")
require("lua/vardump.lua")

Creature = {}
Creature.__index = Creature

function Creature.create(game,number,gx,gy,live)
	
	local temp = {}
	setmetatable(temp, Creature)
	temp.freeze = math.random()
	temp.hover = false -- whether the mouse is hovering over the Creature
	temp.click = false -- whether the mouse has been clicked on the Creature
	temp.number = number + 1 -- the text in the Creature
	temp.width = graphics["creature"][temp.number]:getWidth()
	temp.height = graphics["creature"][temp.number]:getHeight()
	temp.trace = false
	temp.locked   = 0
	temp.gx = gx
	temp.gy = gy
	temp.x = GRID_SIZE*gx + GRID_SIZE/2
	temp.y = GRID_SIZE*gy + GRID_SIZE/2
	temp.slowly = false -- 减速
	temp.slowly_time = 0 -- 减速时间
	temp.slowly_angle = 0
	temp.hidden = false
	temp.antihidden_time = 0 --破坏隐藏时间
 	temp.update_time = 1
	temp.drawMap =  { n = COL_NUMS *  ROW_NUMS }
	temp.foundpath = false
	temp.game = game
	if(game~=nil) then 
		temp.LastBlockhouseCount = #game.blockhouses
	else
	    temp.LastBlockhouseCount = 0	
	end

	temp.map = {}
	temp.pass = false -- 是否到达终点 
	temp.startIndex = temp.gx + temp.gy * COL_NUMS
	temp.live = live
	temp.off_angle = 0
	temp.firstx = 0  --第一步x坐标
	temp.firsty = 0  --第一步y坐标
	temp.needbuildpath = false
	if(gx >=0 and gx <=3) then -- from left
		temp.angle = 0
		temp.from = 1 -- left
		temp.endIndex = (gy+1) * COL_NUMS - 1 -- 475
		temp.firstx = 50

	else  -- from top
		temp.angle = 90
		temp.from = 0 -- top
		temp.endIndex = COL_NUMS * (ROW_NUMS-1) + gx -- 882
		temp.firsty = 50
	end
	
	-- 初始化同目的地的坐标差

	if(temp.from == 0) then --top
		temp.endX = temp.x
    	temp.endY = battlearea.top + (temp.endIndex % COL_NUMS )*GRID_SIZE
	else -- left
	    temp.endX = battlearea.left + math.floor(temp.endIndex / COL_NUMS) * GRID_SIZE
    	temp.endY = temp.y
	end

    temp.dx = temp.endX - temp.x
	temp.dy = temp.endY - temp.y



	if(number == 0) then
		temp.health = 8
		temp.award = 6
		temp.money = 4
		temp.speed = 3
	elseif(number == 1) then
		temp.health = 30
		temp.award = 10
		temp.money = 8
		temp.speed = 3
	elseif(number == 2) then
		temp.health = 15
		temp.award = 7
		temp.money = 5
		temp.speed = 3
	elseif(number == 3) then
		temp.health = 15
		temp.award = 8
		temp.money = 6
		temp.speed = 6
	elseif(number == 4) then
		temp.health = 20
		temp.award = 10
		temp.money = 10
		temp.speed = 3
		temp.hidden = true
	elseif(number == 5) then  --air
		temp.health = 15
		temp.award = 6
		temp.money = 4
		temp.speed = 2
	elseif(number == 6) then
		temp.health = 20
		temp.award = 15
		temp.money = 15
		temp.speed = 3
	elseif(number == 7) then
		temp.health = 100
		temp.award = 100
		temp.money = 100
		temp.speed = 3
	else
		temp.health = 10
		temp.award = 5
		temp.money = 2
		temp.speed = 3
	end
	temp.base_health = temp.health
	temp.base_money = temp.money
	temp.base_award = temp.award 
	if( game.stage > 1) then
	temp.health = temp.base_health * (0.5*game.stage)
	temp.money =  math.floor(temp.base_money * (1 + math.log(game.stage) * 0.25 ))
	temp.award =  math.floor(temp.base_award + math.log(game.stage))
	end
				
	temp.blood = temp.health 
	
	return temp
	
end
function Creature:_x()
	return battlearea.left + (gx) * GRID_SIZE
end
function Creature:_y()
	return battlearea.top + (gy) * GRID_SIZE
end
function Creature:draw()
	
	local currentX = self.x
	local currentY = self.y
	love.graphics.setLine( 1 )
    love.graphics.setLineStyle( "smooth" )
    love.graphics.setColor(color["grid_close"])
	
	if(debug) then
		-- 画线路图 
		if(self.drawMap ~= nil and self.map ~= nil) then
			for i = 1, #self.map do
				nextX = self:getX(self.map[i]) * GRID_SIZE + GRID_SIZE /2
				nextY = self:getY(self.map[i]) * GRID_SIZE *2 /2
				love.graphics.line( currentX, currentY, nextX ,nextY )
				currentX = nextX
				currentY = nextY
			end
	
		end
	end
	-- 画血条
	local m = math.max(self.width,self.height)
	love.graphics.setColor(color["blood"]) 
	love.graphics.rectangle( "fill", self.x - m/2, self.y-m/2 - 5, m, 2 ) 
	
	love.graphics.setColor(color["green"]) 
	love.graphics.rectangle( "fill", self.x-m/2, self.y-m/2 - 5, m*self.health/self.blood, 2 ) 
	
	
	if(self.freeze <=0) then

			if self.hidden == true then
			    local oldcolor = love.graphics.getColor()
				
				love.graphics.setColorMode("modulate")
				love.graphics.setColor(255, 255, 255, 100)
    			love.graphics.draw(graphics["creature"][self.number], self.x, self.y, angleToradians(self.angle),  1, 1, self.width/2, self.height/2)
				if(oldcolor >0) then
					love.graphics.setColor(oldcolor)
				end
				love.graphics.setColorMode("replace")
			else
				love.graphics.draw(graphics["creature"][self.number], self.x, self.y, angleToradians(self.angle),  1, 1, self.width/2, self.height/2)
			end
			if(self.slowly == true) then
				--local zoomState = math.max(self.width,self.height) / math.min(graphics["star_circle"]:getWidth(),graphics["star_circle"]:getHeight())
				love.graphics.draw(graphics["star_circle"], self.x, self.y, angleToradians(self.angle + self.slowly_angle),  1  , 1 , graphics["star_circle"]:getWidth()/2, graphics["star_circle"]:getHeight()/2)
			end
		-- 显示敌人状态
		if self.hover and debug  then
   			love.graphics.setColor(color["menu_bg"])
			love.graphics.setFont(font["small"])
			love.graphics.print("object move:"..self.startIndex .. "->" .. self.endIndex, 100, 223)
		end
	end
	
end
function Creature:MoveOnAir(dt)
    local speed = dt*self.speed * 10
    local dx = self.dx
	local dy = self.dy
	
	
	if(self.slowly) then
	    speed = speed * 0.5
	end
	local angle = (270 + math.atan2(dy, dx)*180/math.pi)%360

	
	if(self.trace) then
		print(string.format("self.angle = %d,angle = %d",self.angle,angle))
	end


	if(self.off_angle ~= angle) then
		self.off_angle = angle
		return
	end
	if(self.from == 0)  then --top
		self.angle = self.off_angle + 90
	else  --left
		self.angle = self.off_angle - 90 * 3
	end


	--移动目标

    if(math.abs(dx)>speed or math.abs(dy)>speed) then
		self.x = self.x - speed*math.sin(angle*math.pi/180)
		self.y = self.y + speed*math.cos(angle*math.pi/180)
	end
end
function Creature:ReCaleGridXY()
	local gx = math.floor(self.x / GRID_SIZE)
	local gy = math.floor(self.y / GRID_SIZE)
	self.gx = gx
	self.gy = gy
	self.startIndex = gx + gy * COL_NUMS
end
function Creature:getX(index)
    return index % COL_NUMS
end
function Creature:getY(index)
    return math.floor(index / COL_NUMS)
end
function Creature:MoveOnLand(dt)

	local speed = dt*self.speed * 10
	if(self.slowly) then
	    speed = speed * 0.5
	end
	if(self.map ~= nil and #self.map >0) then
		local currentIndex = self.gx + self.gy * COL_NUMS
		--print(string.format("move out from %d to %d,#self.map = %d",currentIndex,self.endIndex,#self.map))
		--pr(self.map,"map")
		local nextX,nextY
		--print(string.format("check startIndex and endIndex,%d,%d",self.startIndex ,self.endIndex))
        --if(self.map[1] == nil) then
        --    pr(self.map,"map")
        --end
		nextX = self:getX(self.map[1]) * GRID_SIZE + GRID_SIZE /2
		nextY = self:getY(self.map[1]) * GRID_SIZE + GRID_SIZE /2
		if (math.abs(nextX - self.x) + math.abs(nextY - self.y)) < 4 then 			
            table.remove(self.map,1)
			self:ReCaleGridXY()
			self.startIndex = self.gx + self.gy * COL_NUMS
		end

		--print(string.format("self.x=%d,self.y=%d,nextX=%d,nextY=%d",self.x,self.y,nextX,nextY))
		if nextX ~= nil and nextY ~= nil then
			local dx = nextX - self.x
			local dy = nextY - self.y
			local angle = (270 + math.atan2(dy, dx)*180/math.pi)%360
			if(self.trace) then
				print(string.format("self.angle = %d,angle = %d",self.angle,angle))
			end


			if(self.off_angle ~= angle) then
				self.off_angle = angle
				return
			end
			if(self.from == 0) then -- top
				self.angle = self.off_angle + 90
			else --left
				self.angle = self.off_angle - 90 * 3
			end


			--移动目标



			--if(math.abs(dx)>speed or math.abs(dy)>speed) then
				self.x = self.x - speed*math.sin(angle*math.pi/180)
				self.y = self.y + speed*math.cos(angle*math.pi/180)
			--end
		end
	 else -- direct move
		if self.from == 0 and self.y < self.firsty then -- from top
		    self.y = self.y + speed
		end
		if self.from == 1 and self.x < self.firstx then -- from left
		    self.x = self.x + speed
		end
	 end
end
function Creature:update(dt,index)

    if (self.freeze >=0) then
		self.freeze = self.freeze - dt
		return
	end
    if (self.pass) then
        state.health = state.health - 1
        table.remove(state.enemys,index)
		return
	end
    
    if(self.health <=0) then
							--b.host.target = nil
							love.audio.play(sound["creature_die"])
							state.scope = state.scope + self.award
							state.money = state.money + self.money
							table.insert(state.hints,Hint.create("fly",self.award,self.x,self.y))
                            table.remove(state.enemys,index)
                            return
	end
     
	self.hover = false
	
	local x = love.mouse.getX()
	local y = love.mouse.getY()
	
	if (self.slowly_time >0) then
	    self.slowly_time = self.slowly_time - dt
	    self.slowly_angle = (self.slowly_angle + 90 * dt)
		if(debug) then 
		--print("slowly_angle"..self.slowly_angle % 360)
		end
	else
	    self.slowly = false
	end
	if (self.number == 5 ) then --隐形能力的生物
		if(self.antihidden_time > 0) then
	    	self.antihidden_time = self.antihidden_time - dt
		else
	    	self.hidden = true
	    end
	end
	self.update_time = self.update_time + dt
	if (self.update_time > 0.5 and self.number == 7 ) then -- 冰冻生物
		self.update_time = 0
		local maxaff = 0
		for n,bh in pairs(state.blockhouses) do
			if (bh.ice ~= true and bh.live == 1 and (math.abs(self.x - bh.centX) < (GRID_SIZE * 3) and math.abs(self.y - bh.centY) < (GRID_SIZE * 3))) then
				bh.ice = true
				bh.ice_time = 6
				maxaff = maxaff + 1
				if(maxaff >= 1) then
					break
				end
			end
		end
	end

	
	if x > self.x
		and x < self.x + self.width
		and y > self.y - self.height
		and y < self.y then
		self.hover = true
	end
	
	-- 是否到达目标
	
	local gx = math.floor(self.x / GRID_SIZE)
        local gy = math.floor(self.y / GRID_SIZE)

	if  ((self.number == 6) and
	     ((self.from == 0 and gy >29) or (self.from == 1 and gx > 25))) or
		self.startIndex == self.endIndex then --到达目标
		--print("reach") 
		self.pass = true
		love.audio.play(sound.creature_rich_dest)
		return
	end
    
	self.needbuildpath = false;
	if(self.from == 0 and self.y > self.firsty) then --top
    	self.needbuildpath = true
	end
    if(self.from == 1 and self.x > self.firstx) then --left
    	self.needbuildpath = true
	end
	if self.number ~=6 and self.needbuildpath then
	-- 开始寻路
		self:ReCaleGridXY()
		
		if(self.foundpath == false) then

			local startIndex = self.startIndex
			local endIndex = self.endIndex
			
            --print("love.ai.astarfindpath start ")
            self.map = love.ai.astarfindpath( startIndex, endIndex)
            --print("love.ai.astarfindpath end")
			
            
			if (self.map and #self.map>0) then
				self.foundpath = true
            else
                print("path not found:%d-%d",startIndex,endIndex)
                local gamemaps = astargetdata()
                pr(gamemaps,"gamemaps")
                self.health = 0
			end
		end

            local isNeedReBuildPath = false
		 
            if (self.map and #self.map>0)then
			for i = 1, #self.map do
				local index =  self.map[i]

				if index >4 and love.ai.astargetindexdata(index) == 1 then
					isNeedReBuildPath = true
					break
				end

			end
             
		end
		if isNeedReBuildPath  then
	  		self.foundpath = false
		end
	end
	
	
	-- 朝出口移动
	if(self.number == 6) then
	    self:MoveOnAir(dt)
	else
    	self:MoveOnLand(dt)
    end
end

function Creature:mousepressed(x, y, Creature)
	
	if self.hover then
		if audio then
			love.audio.play(sound["click"])
		end
		return true
	end
	
	return false
	
end
