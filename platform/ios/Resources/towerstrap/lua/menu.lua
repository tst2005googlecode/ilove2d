-- Menu State
-- Main menu...
Menu = {}
Menu.__index = Menu

function Menu.create()
	-- Set the background color to soothing pink.
	love.graphics.setBackgroundColor(0xff, 0xf1, 0xf7)
	--love.graphics.translate(640/2, 480/2)
 
	love.graphics.setBlendMode("alpha") 
	local temp = {}
	setmetatable(temp, Menu)
	temp.button = {	new = Button.create("New Game", love.graphics.getWidth( ) /2, 250),
					instructions = Button.create("Instructions", love.graphics.getWidth( ) /2, 300),
					options = Button.create("Options", love.graphics.getWidth( ) /2, 350),
					quit = Button.create("Quit", love.graphics.getWidth( ) /2, 550) }
	return temp
end
 
function Menu:draw()
	--love.graphics.setBackgroundColor(255,255,255)
	love.graphics.setColor(255, 255, 255, 200)
	love.graphics.draw(graphics["logo"], (love.graphics.getWidth( ) - graphics["logo"]:getWidth()) /2 ,
		(love.graphics.getHeight( ) - graphics["logo"]:getHeight()) /2)
	love.graphics.setColor(color["menu_border"])
	love.graphics.setLine(4,"rough")
	love.graphics.rectangle( "line", 100, 0, love.graphics.getWidth( ) -200,  love.graphics.getHeight( ) ) 
	love.graphics.setColor(color["menu_bg"])
	love.graphics.setLine(1)
	love.graphics.rectangle( "fill", 102, 2, love.graphics.getWidth( ) -204,  love.graphics.getHeight( )-4 ) 
	
	for n,b in pairs(self.button) do
		b:draw()
	end

end

function Menu:update(dt)
	
	for n,b in pairs(self.button) do
		b:update(dt)
	end
	
end

function Menu:mousepressed(x,y,button)
	
	for n,b in pairs(self.button) do
		if b:mousepressed(x,y,button) then
			if n == "new" then
				state = Game.create()
			elseif n == "instructions" then
				state = Instructions.create()
			elseif n == "options" then
				state = Options.create()
			elseif n == "quit" then
				love.system.exit()
			end
		end
	end
	
end

function Menu:keypressed(key)
end

