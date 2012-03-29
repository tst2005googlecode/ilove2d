-- Includes

require("menu.lua")
require("game.lua")

function love.load() 
 	
	-- Variables
	debug = true
	audio = true			-- whether audio should be on or off
	state = Menu.create()	-- current game state
	
	-- Setup
	--love.graphics.setBackgroundColor(color["background"])
	--love.audio.play(music["menu"], 0)
	--love.audio.setVolume(0.3);

	-- randomize
	math.randomseed(os.time())
end 
function love.draw()
	state:draw()
end

function love.update(dt)
 
	state:update(dt)
	love.timer.sleep(1)
 
end


function love.mousepressed(x, y, button)

	state:mousepressed(x,y,button)

end


function love.keypressed(key)
	
	if key == love.key_f4 and (love.keyboard.isDown(love.key_ralt) or love.keyboard.isDown(love.key_lalt)) then
		love.system.exit()
	end
	
	state:keypressed(key)

end 
