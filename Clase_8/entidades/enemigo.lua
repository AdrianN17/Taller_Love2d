local Class  = require "libs.hump.class"
local lsm = require "libs.lsm.statemachine"
local eliminar = require "entidades.eliminar"
local Bala = require "entidades.bala"

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


	self.body:setMass( 0 )
	self.body:setInertia( 0 )

	self.fixture:setDensity(0)

	self.body:setLinearDamping(5)

	self.body:setAngle(0)

	--estadisticas
	self.hp=2
	self.velocidad = 500

	--diferenciar player enemigo
	self.creador = 10
	self.fixture:setGroupIndex(-self.creador)

	eliminar.init(self,"enemigos")
end

function enemigo:draw()
	local x,y,w,h = self.spritesheet[self.iterator_quad]:getViewport( )

	love.graphics.draw(self.img,self.spritesheet[self.iterator_quad],self.ox,self.oy,self.radio,self.spritesheet.scale,self.spritesheet.scale,w/2,h/2)
end

function enemigo:update(dt)

	self.ox,self.oy=self.body:getX(),self.body:getY()
end

return enemigo