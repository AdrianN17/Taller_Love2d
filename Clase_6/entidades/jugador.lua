local Class  = require "libs.hump.class"

local jugador = Class{}

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

	self.body:setMass( 0 )
	self.body:setInertia( 0 )

	self.fixture:setDensity(0)

	self.body:setLinearDamping(5)

	self.body:setAngle(0)
	
	self.velocidad = 200

	--estados

	self.movimiento = {moverse = false}
	self.estado = {disparando = false}


end

function jugador:draw()
	local x,y,w,h = self.spritesheet[self.iterator_quad]:getViewport( )

	love.graphics.draw(self.img,self.spritesheet[self.iterator_quad],self.ox,self.oy,self.radio,self.spritesheet.scale,self.spritesheet.scale,w/2,h/2)
end

function jugador:update(dt)

	if self.movimiento.moverse then
		self:moverse(dt)
	end

	self.ox,self.oy=self.body:getX(),self.body:getY()
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

return jugador