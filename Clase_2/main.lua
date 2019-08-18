local i=0 
local imagen=nil
local music= nil
local golpe=nil

local ox,oy = 100,300
local lado = 1
local w,h
local r = 0
	
function love.load()
	imagen = love.graphics.newImage("Hamster.png")
	w,h = imagen:getDimensions( )

	music = love.audio.newSource("hamster.wav","stream" )


	music:setLooping(true)
	music:play()

	golpe = love.audio.newSource("golpe.ogg","static" )
end

function love.draw()
	love.graphics.print("click n°" .. i ,100,100)

	love.graphics.draw(imagen,ox,oy,r,lado,1,w/2,h/2)
end

function love.update(dt)
	r=r+dt
end

function love.keypressed(key)
	if key=="a" then
		ox=ox-5
		lado = -1
	elseif key=="d" then
		ox=ox+5
		lado = 1
	end
end

function love.mousepressed(x,y,button)
	ox,oy=x,y
	golpe:play()

	i=i+1
end