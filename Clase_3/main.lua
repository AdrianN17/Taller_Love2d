local i=0 
local imagen=nil
local music= nil
local golpe=nil

local world=nil

local hamster = {}
local suelo = {}

local barrera = {}
	
function love.load()

	love.physics.setMeter(64)

	world = love.physics.newWorld(0, 9.81*64, true)

	hamster.x,hamster.y = 100,300
	hamster.r = 0
	hamster.lado = 1

	hamster.body = love.physics.newBody(world,hamster.x,hamster.y, "dynamic")
	hamster.shape = love.physics.newCircleShape(40)
	hamster.fixture = love.physics.newFixture(hamster.body,hamster.shape)

	hamster.fixture:setRestitution(0.8)

	hamster.ox,hamster.oy = hamster.body:getX(), hamster.body:getY()

	hamster.img = love.graphics.newImage("Hamster.png")

	hamster.w,hamster.h = hamster.img:getDimensions( )

	music = love.audio.newSource("hamster.wav","stream" )

	music:setLooping(true)
	music:play()

	golpe = love.audio.newSource("golpe.ogg","static" )

	suelo.x1,suelo.y1 = 0, 400
	suelo.x2,suelo.y2 = 600, 400

	suelo.body = love.physics.newBody(world,0,0, "static")
	suelo.shape = love.physics.newEdgeShape(suelo.x1,suelo.y1,suelo.x2,suelo.y2)
	suelo.fixture = love.physics.newFixture(suelo.body,suelo.shape)

	barrera.x,barrera.y = 200,200
	barrera.w,barrera.h = 50, 100

	barrera.body = love.physics.newBody(world,0,0, "dynamic")
	barrera.shape = love.physics.newRectangleShape(barrera.x,barrera.y,barrera.w,barrera.h)
	barrera.fixture = love.physics.newFixture(barrera.body,barrera.shape)

end

function love.draw()
	love.graphics.print("click n°" .. i ,100,100)

	love.graphics.draw(hamster.img,hamster.ox,hamster.oy,hamster.r,hamster.lado,1,hamster.w/2,hamster.h/2)

	draw_fisicas()
end

function love.update(dt)
	world:update(dt)

	hamster.ox,hamster.oy = hamster.body:getX(), hamster.body:getY()

	--hamster.r=hamster.r+dt
	hamster.r = hamster.body:getAngle()
end

function love.keypressed(key)
	if key=="a" then
		hamster.body:applyLinearImpulse(-100,0)
		hamster.lado = -1
	elseif key=="d" then
		hamster.body:applyLinearImpulse(100,0)
		hamster.lado = 1
	elseif key == "w" then
		hamster.body:applyLinearImpulse(0,-250)
	end
end

function love.mousepressed(x,y,button)
	hamster.body:setPosition(x,y)
	golpe:play()

	i=i+1
end

function draw_fisicas()
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