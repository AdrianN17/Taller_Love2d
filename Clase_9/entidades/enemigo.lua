local Class  = require "libs.hump.class"
local lsm = require "libs.lsm.statemachine"
local eliminar = require "entidades.eliminar"
local Bala = require "entidades.bala"
local fsm = require "libs.lsm.statemachine"

local enemigo = Class{
	__includes={eliminar}
}

function enemigo:init(entidad,x,y)
	self.entidad = entidad

	self.ox,self.oy = x,y

	self.entidad:nuevo_objeto(self,"enemigos")

	--imagen

	self.img = self.entidad.sprites_todos.spritesheet
	self.spritesheet = self.entidad.sprites_todos.enemigo

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
	self.fixture:setUserData( {data="enemigos", pos=2, obj=self} )

	--vision
	self.shape_vision = love.physics.newCircleShape(0,75,100)
	self.fixture_vision = love.physics.newFixture(self.body, self.shape_vision )
	self.fixture_vision:setUserData( {data="enemigos_vision", pos=6, obj=self} )
	self.fixture_vision:setSensor(true)


	self.body:setMass( 0 )
	self.body:setInertia( 0 )

	self.fixture:setDensity(0)

	self.body:setLinearDamping(5)

	self.body:setAngle(0)

	--estadisticas
	self.hp=2
	self.velocidad = 400
	self.hp = 3

	--diferenciar player enemigo
	self.creador = 10
	self.fixture:setGroupIndex(-self.creador)

	--creacion automata
	self.estados = fsm.create({
		initial = 'buscar',
		  events = {
		    { name = 'buscando',  from = 'atacar',  to = 'buscar' },
		    { name = 'atacando', from = 'buscar', to = 'atacar'    }
		}})

	--angulo aleatorio
	self.tiempo_angulo=0
	self.max_tiempo_angulo=2.5

	--contador balas
	self.tiempo_disparando = 1
	self.max_tiempo_disparando = 1





	eliminar.init(self,"enemigos")

end

function enemigo:draw()
	local x,y,w,h = self.spritesheet[self.iterator_quad]:getViewport( )

	love.graphics.draw(self.img,self.spritesheet[self.iterator_quad],self.ox,self.oy,self.radio,self.spritesheet.scale,self.spritesheet.scale,w/2,h/2)

	love.graphics.print(self.estados.current,self.ox,self.oy-100)
end

function enemigo:update(dt)

	if self.estados.current=="buscar" then

		if self.toco_pared then

			local angulo_adicional = 0
			local r = love.math.random(1,2)
	    	if r == 1 then
	       		angulo_adicional= math.pi/2
	       	elseif r == 2 then
	       		angulo_adicional= math.pi/2
	       	end


			self.radio= -self.radio+angulo_adicional
 			self.body:setAngle(self.radio)
 			self.tiempo_angulo=0
 			self.toco_pared=false
		end

		self:angulo_aleatorio(dt)
		self:moverse(dt)

	elseif self.estados.current=="atacar" then

		if self.blanco then
			self:calcular_angulo_mirada(self.blanco)
		end

		self.tiempo_disparando=self.tiempo_disparando+dt

		if self.tiempo_disparando>self.max_tiempo_disparando then

		 	self:crear_balas()

			self.tiempo_disparando=0
		end
	end

	self.ox,self.oy=self.body:getX(),self.body:getY()

	if self.hp<1 then
        self:remover()
    end
end

function enemigo:moverse(dt)
	local radio = self.radio+math.pi/2

	local x,y = math.cos(radio), math.sin(radio)

	local mx,my=x*self.velocidad*dt,y*self.velocidad*dt
	local vx,vy=self.body:getLinearVelocity()



	if vx<self.velocidad or vy<self.velocidad then
		self.body:applyLinearImpulse(mx,my)
	end
end

function enemigo:angulo_aleatorio(dt)
	self.tiempo_angulo=self.tiempo_angulo+dt

	if self.tiempo_angulo>self.max_tiempo_angulo then
		self.radio = math.rad(love.math.random(0,18)*20)
		self.body:setAngle(self.radio)

		self.tiempo_angulo=0
	end
end

function enemigo:crear_balas()
	Bala(self.entidad,self.ox,self.oy,self.radio,self.creador)
end

function enemigo:calcular_angulo_mirada(personaje)
	local x,y = personaje.ox,personaje.oy

	 self.radio = math.atan2(self.oy-y, self.ox-x) +math.pi/2
	 self.body:setAngle(self.radio)
end

return enemigo