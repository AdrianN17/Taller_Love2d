Gamestate =  require "libs.hump.gamestate"

Juego = require "entidades.juego"
Menu = require "escenas.menu"

function love.load()
	love.graphics.setNewFont("assets/font/lunchds.ttf", 20)

	
	Gamestate.registerEvents()
  	Gamestate.switch(Menu)
end




function draw_fisicas(world)
	for _, body in pairs(world:getBodies()) do
	    for _, fixture in pairs(body:getFixtures()) do
	        local shape = fixture:getShape()
	 
	        if shape:typeOf("CircleShape") then
	            local cx, cy = body:getWorldPoints(shape:getPoint())
	            love.graphics.circle("line", cx, cy, shape:getRadius())
	        elseif shape:typeOf("PolygonShape") then
	            love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
	        else
	            love.graphics.line(body:getWorldPoints(shape:getPoints()))
	        end
	    end
	end
end