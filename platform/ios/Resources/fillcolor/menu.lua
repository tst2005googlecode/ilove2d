-- Menu State
-- Main menu...
Menu = {}
Menu.__index = Menu

function Menu.create()
 
	love.graphics.setFont(10)
	love.graphics.setBackgroundColor(255,255,255)
	
	local temp = {}
	setmetatable(temp, Menu)
	temp.bg = love.graphics.newImage("assets/image 57.jpg")
	temp.t2 = love.graphics.newImage("assets/shape85.png")
	temp.t1 = love.graphics.newImage("assets/shape92.png")
	temp.pen = love.graphics.newImage("assets/shape104.png")
	temp.colorblock = love.graphics.newImage("assets/shape81.png")
	temp.buttonstart = love.graphics.newImage("assets/shape65.png")
	temp.bg = love.graphics.newImage("/assets/image 57.jpg")
	return temp
end
 
function Menu:update(dt)
 
end
function Menu:draw()
	 
	love.graphics.draw(self.bg,0,0)
	love.graphics.draw(self.t1,98,33) 
	love.graphics.draw(self.t2,218,142) 	
	love.graphics.draw(self.pen,400,112) 
	love.graphics.draw(self.colorblock,300,303) 
	love.graphics.draw(self.buttonstart,100,250)
	love.graphics.setFont(24)
	love.graphics.print("START",120,260)
	
	love.graphics.print("fps:" .. love.timer.getFPS(),0,0)
end
function Menu:mousepressed(x,y)
if (x > 120 and x < (120+166) and y > 260 and y < (260 + 50)) then
    state = Game.create()
    print("game create")
end
end

function Menu:keypressed(key)
end