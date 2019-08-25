local img = {}

img.spritesheet = love.graphics.newImage("assets/img/spritesheet.png")

img.jugador={}
img.jugador[1] = love.graphics.newQuad(408,115,66,113, img.spritesheet:getDimensions())
img.jugador[2] = love.graphics.newQuad(272,345,66,113, img.spritesheet:getDimensions())

img.jugador.scale = 1

img.enemigo={}
img.enemigo[1] = love.graphics.newQuad(408,0,66,113, img.spritesheet:getDimensions())
img.enemigo[2] = love.graphics.newQuad(340,0,66,113, img.spritesheet:getDimensions())

img.enemigo.scale = 1

img.bala = {}
img.bala[1] = love.graphics.newQuad(120,29,10,10, img.spritesheet:getDimensions())

img.bala.scale = 1

return img
