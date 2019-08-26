local Class  = require "libs.hump.class"
local Bala = require "entidades.bala"
local eliminar = require "entidades.eliminar"

local jugador = Class{
	__includes = {eliminar}
}

function jugador:init(entidad,x,y)
	self.entidad = entidad

	self.ox,self.oy = x,y


	self.entidad:nuevo_objeto(self,"jugadores")

	self.img = self.entidad.sprites_todos.spritesheet
	self.spritesheet = self.entidad.sprites_todos.jugador

	self.radio = 0
	self.iterator_quad = 1


	--fisicas

	local poligono = {
		0 , 55,
		26 , 3,
		12 , -48,
		-12 , -48,
		-26 , 3
	}

	self.body = love.physics.newBody(self.entidad.world,x,y,"dynamic")

	self.shape = love.physics.newPolygonShape(poligono)

	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.fixture:setUserData( {data="personajes", pos=1, obj=self} )

	--creando puntos de cañon

	self.puntos = {}

	self.puntos[1]={}
	self.puntos[1].shape = love.physics.newCircleShape(25,15,5)
	self.puntos[1].fixture = love.physics.newFixture(self.body, self.puntos[1].shape)
	self.puntos[1].fixture:setSensor(true)
	self.puntos[1].fixture:setUserData( {data="puntos", pos=5} )
	self.puntos[1].radio = math.rad(-15)

	self.puntos[2]={}
	self.puntos[2].shape = love.physics.newCircleShape(-25,15,5)
	self.puntos[2].fixture = love.physics.newFixture(self.body, self.puntos[2].shape)
	self.puntos[2].fixture:setSensor(true)
	self.puntos[2].fixture:setUserData( {data="puntos", pos=5} )
	self.puntos[2].radio = math.rad(15)

	self.body:setMass( 0 )
	self.body:setInertia( 0 )

	self.fixture:setDensity(0)

	self.body:setLinearDamping(5)

	self.body:setAngle(0)


	--estadisticas

	self.hp=5
	self.velocidad = 500
	self.hp = 5

	--estados

	self.movimiento = {moverse = false}
	self.estado = {disparando = false}

	--contador balas

	self.tiempo_disparando = 1
	self.max_tiempo_disparando = 1

	--diferenciar player enemigo

	self.creador = 1
	self.fixture:setGroupIndex(-self.creador)

	eliminar.init(self,"jugadores")
end

function jugador:draw()
	local x,y,w,h = self.spritesheet[self.iterator_quad]:getViewport( )

	love.graphics.draw(self.img,self.spritesheet[self.iterator_quad],self.ox,self.oy,self.radio,self.spritesheet.scale,self.spritesheet.scale,w/2,h/2)
end

function jugador:update(dt)

	self:get_radio()

	if self.movimiento.moverse then
		self:moverse(dt)
	end

	if self.estado.disparando then
		self.tiempo_disparando=self.tiempo_disparando+dt

		if self.tiempo_disparando>self.max_tiempo_disparando then

		 	self:crear_balas()

			self.tiempo_disparando=0
		end
	end

	self.ox,self.oy=self.body:getX(),self.body:getY()

	if self.hp<1 then
		self.entidad:guardar_score()
        self:remover()
    end
end

function jugador:keypressed(key)
	if key=="space" then
		self.movimiento.moverse=true
	end
end

function jugador:keyreleased(key)
	if key=="space" then
		self.movimiento.moverse=false
	end
end

function jugador:mousepressed(x,y,button)
	if button == 1 then
		self.estado.disparando=true
	end
end

function jugador:mousereleased(x,y,button)
	if button == 1 then
		self.estado.disparando=false
		self.tiempo_disparando=self.max_tiempo_disparando 
	end
end


function jugador:moverse(dt)
	local radio = self.radio+math.pi/2

	local x,y = math.cos(radio), math.sin(radio)

	local mx,my=x*self.velocidad*dt,y*self.velocidad*dt
	local vx,vy=self.body:getLinearVelocity()



	if vx<self.velocidad or vy<self.velocidad then
		self.body:applyLinearImpulse(mx,my)
	end
end

function jugador:get_radio()
	local rx,ry = self.entidad:getxy()

	local radio =  math.atan2( ry-self.oy, rx -self.ox)
	self.radio = radio -math.pi/2

	self.body:setAngle(self.radio)
end

function jugador:crear_balas()
	local disparo_sonido = self.entidad.sonidos_todos.canon

	if disparo_sonido:isPlaying() then 
		disparo_sonido:stop() 
		disparo_sonido:play() 
	else 
		disparo_sonido:play() 
	end


	for _, punto in ipairs(self.puntos) do
		local shape = punto.fixture:getShape()
		local px,py = self.body:getWorldPoints(shape:getPoint())

		Bala(self.entidad,px,py,self.radio+punto.radio,self.creador)
	end
end

return jugador