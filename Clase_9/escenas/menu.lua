local serialize = require "libs.ser.ser"

menu = Gamestate.new()

function menu:init()
	self.ui = require "assets.ui.ui"
end

function menu:enter(from)
    local data=nil
	self.score=0

	if love.filesystem.getInfo("score.lua") then
      data =love.filesystem.load("score.lua")()
      self.score=data.score
    else
    	love.filesystem.write("score.lua",serialize({score=0}))
    end
end

function menu:draw()

    love.graphics.draw(self.ui.fondo,0.0)

    love.graphics.draw(self.ui.logo,175,200)

    love.graphics.print("Presione enter para continuar", 300,400)

    love.graphics.print("Su puntuacion : " .. self.score,350,470)

end

function menu:keypressed(key)
	if key=="return" then
		Gamestate.switch(Juego)
	end
end


return menu