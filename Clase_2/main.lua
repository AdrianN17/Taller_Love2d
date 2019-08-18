local i=0 
local imagen=nil
	
function love.load()
	imagen = love.graphics.newImage("Hamster.png")
end

function love.draw()
	love.graphics.print("hola n°" .. i ,100,100)

	love.graphics.draw(imagen,100,300)
end

function love.update(dt)
	i=i+1
end