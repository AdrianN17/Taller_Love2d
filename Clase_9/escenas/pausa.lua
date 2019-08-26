pausa = Gamestate.new()

function pausa:init()
    self.ui = require "assets.ui.ui"
end

function pausa:enter(from)
    self.from = from 
end

function pausa:draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    self.from:draw()
    love.graphics.draw(self.ui.pausa,375,250)

    love.graphics.print("Presione p para volver al juego", 325,400)
end

function pausa:keypressed(key)
  if key == 'p' then
    return Gamestate.pop() 
  end
end

return pausa 