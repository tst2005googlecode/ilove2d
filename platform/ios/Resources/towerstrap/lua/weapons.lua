-----------------------
-- NO: A game of numbers
-- Created: 23.08.08 by Michael Enger
-- Version: 0.2
-- Website: http://www.facemeandscream.com
-- Licence: ZLIB
-----------------------
-- Handles buttons and such.
-----------------------

Weapons = {}
Weapons.__index = Weapons

function Weapons.create(x,y)
	
	local temp = {}
	setmetatable(temp, Weapons)
	temp.hover = false -- whether the mouse is hovering over the button
	temp.click = false -- whether the mouse has been clicked on the button
	temp.name = "" -- the text in the button
	temp.width = 40*7
	temp.height = 40
	temp.selected = -1
	temp.x = x
	temp.y = y
	temp.tipboard_x = x
	temp.tipboard_y = y - 45
	return temp
	
end
function Weapons:getSelected()
	return self.selected;
end
function Weapons:draw()
	--draw weapon tips baord
	love.graphics.setColor(color["menu_bg"])
	love.graphics.setLine(1)
	love.graphics.rectangle( "fill", self.tipboard_x, self.tipboard_y , self.width, self.height) 
	local hoverItem = -1
	if not self.hover then
 		if(debug) then
			love.graphics.print("weapons leave", 100*1.6, 120*1.6) 
		end
	else
		if(debug) then
		love.graphics.setColor(color["menu_bg"])
		love.graphics.print("weapons hover", 100*1.6, 120*1.6) 
		
		end
		local x = love.mouse.getX()
		local y = love.mouse.getY()
		hoverItem = self:getItemByPostion(x,y)
		self:DrawObjTips(hoverItem)
	end
	--draw weapons images
	
	love.graphics.draw(graphics["weapons"], self.x , self.y)
	if(debug) then
		love.graphics.setColor(color["menu_bg"])
		love.graphics.print("weapons selected: " .. self.selected, 100*1.6, 100*1.6) 
	end
	if self.selected then
		if hoverItem < 0 then
			self:DrawObjTips(self.selected)
		end
		love.graphics.setColor(color["obj_selected"])
		love.graphics.setLine(2)
		love.graphics.rectangle( "line", self.x  + (self.selected - 1) * 40, self.y , 40, 40)
	end	
end
function Weapons:DrawObjTips(index)
		love.graphics.setColor(color["white"])
		--love.graphics.setFont(font["large"])
		love.graphics.setFont(font["impact"])
		if index == 1 then
			love.graphics.print("SNIPER",self.tipboard_x,self.tipboard_y)
		elseif index == 2 then
			love.graphics.print("ROCKET LUNCHER",self.tipboard_x,self.tipboard_y)
		elseif index == 3 then
			love.graphics.print("CANNON",self.tipboard_x,self.tipboard_y)
		elseif index == 4 then
			love.graphics.print("SHOCK",self.tipboard_x,self.tipboard_y)
		elseif index == 5 then
			love.graphics.print("AIR",self.tipboard_x,self.tipboard_y)
		elseif index == 6 then
			love.graphics.print("EARTHQUAKE",self.tipboard_x,self.tipboard_y)
		elseif index == 7 then
			love.graphics.print("RADAR",self.tipboard_x,self.tipboard_y)
		end
		
		
end
function Weapons:update(dt)
	
	self.hover = false
	local x = love.mouse.getX()
	local y = love.mouse.getY()
	
	if x > self.x
		and x < self.x + self.width
		and y > self.y
		and y < self.y + self.height then
		self.hover = true
	end
	
end
function Weapons:getItemByPostion(x,y)
	return math.floor(( x - self.x)/ 40) + 1
end
function Weapons:mousepressed(x, y, button)
	
	if self.hover then
		--print("x:" .. x)
		--print("self.x:" .. self.x)
		self.selected = self:getItemByPostion(x,y)
		if(self.selected > 7) then
		    self.selected = 7
		end
		state.gselectedBlockhouse = nil
		if audio then
			love.audio.play(sound["click"])
		end
		return true
	end
	
	return false
	
end

function Weapons:unSelected()
  self.selected = -1
end
