-- Game State
-- Game...
Game = {}
Game.__index = Game

function Game.create()
	local temp = {}
	setmetatable(temp, Game)
	temp.bg = nil
	temp.pPoint = {}
    temp.source = nil
    print("game created")
	return temp
end
function Game:newPaddedImage(filename)
    
    if(self.source == nil) then
    self.source = love.image.newImageData(filename)
    end
    local w, h = self.source:getWidth(), self.source:getHeight()
    
    -- Find closest power-of-two.
    local wp = math.pow(2, math.ceil(math.log(w)/math.log(2)))
    local hp = math.pow(2, math.ceil(math.log(h)/math.log(2)))
    
    -- Only pad if needed:
    if wp ~= w or hp ~= h then
        local padded = love.image.newImageData(wp, hp)
        padded:paste(self.source, 0, 0)
        return love.graphics.newImage(padded)
    end
    
    return self:newImage(self.source)
end




function Game:Fill4(x,y, r,g,b,a, r1,g1,b1,a1)
    local pPoint = {}
    local nNum  = 1
    table.insert(pPoint, {x,y})
    
    i = 0;
    while(i < nNum) do
     
         
        --填充左边的点
        local r2,g2,b2,a2
         
        local x,y = pPoint[i+1][1] -1,pPoint[i+1][2]
         
        r2,g2,b2,a2 = source:getPixel(x,y)
        if(r2 == r and g2 == g and b2 == b) then
            source:setPixel(x,y, r1,g1,b1,a1)
            table.insert(pPoint, {x,y})
            nNum = nNum+1
        end
        --填充右边的点
        local x,y = pPoint[i+1][1] +1,pPoint[i+1][2]
         
        r2,g2,b2,a2 = source:getPixel(x,y)
        if(r2 == r and g2 == g and b2 == b) then
            source:setPixel(x,y, r1,g1,b1,a1)
            table.insert(pPoint, {x,y})
            nNum = nNum+1
        end
        --填充上边的点
        local x,y = pPoint[i+1][1],pPoint[i+1][2]-1
         
        r2,g2,b2,a2 = source:getPixel(x,y)
        if(r2 == r and g2 == g and b2 == b) then
            source:setPixel(x,y, r1,g1,b1,a1)
            table.insert(pPoint, {x,y})
            nNum = nNum+1
        end
        --填充下边的点
        local x,y = pPoint[i+1][1],pPoint[i+1][2]+1
         
        r2,g2,b2,a2 = source:getPixel(x,y)
        if(r2 == r and g2 == g and b2 == b) then
            source:setPixel(x,y, r1,g1,b1,a1)
            table.insert(pPoint, {x,y})
            nNum = nNum+1
        end
        i = i +1
       
        if(i > 10000) then
		break
		end
    end
    pPoint = {}
    self.bg = self:newPaddedImage("/assets/shape47.png")
    
end
function Game:update(dt)
   print "game.update"
   if(self.bg == nil) then
   self.bg = self:newPaddedImage("/assets/shape47.png")
   end
   
end
function Game:draw()
     
    love.graphics.draw(self.bg,0,0,0,1,1,0,0)
     
end 
function Game:mousepressed(x,y)
    print(string.format("x:%d,y:%d",x, y))
	if(x < self.bg:getWidth() and y < self.bg:getHeight()) then
		r,g,b,a = source:getPixel(x,y)
		print(string.format("mouse point rgb:%d,%d,%d", r, g, b))
		self:Fill4(x,y, r,g,b,a, 0,0,0,a)
	end
    
end

function Game:keypressed(key)
end