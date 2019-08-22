local Class  = require "libs.hump.class"
local eliminar = require "entidades.eliminar"

local bala = Class{
	__includes = {eliminar}
}

function bala:init(entidad,x,y,radio,creador)
	self.entidad = entidad

	self.entidad:nuevo_objeto(self,"balas")

	self.img = self.entidad.sprites_todos.spritesheet
	self.spritesheet = self.entidad.sprites_todos.bala

	self.velocidad = 500
	self.radio = radio+math.pi/2

	self.body = love.physics.newBody(self.entidad.world,x,y,"dynamic")
	self.shape = love.physics.newCircleShape(5)
	self.fixture = love.physics.newFixture(self.body, self.shape)

	self.fixture:setGroupIndex(-creador)
	self.fixture:setUserData( {data="balas", pos=3, obj=self} )

	self.ox,self.oy = x,y

	eliminar.init(self,"balas")
end

function bala:draw()
	local x,y,w,h = self.spritesheet[1]:getViewport( )

	love.graphics.draw(self.img,self.spritesheet[1],self.ox,self.oy,self.radio,self.spritesheet.scale,self.spritesheet.scale,w/2,h/2)
end

function bala:update(dt)

	local x,y = math.cos(self.radio), math.sin(self.radio)

	local mx,my=x*self.velocidad*dt,y*self.velocidad*dt
	local vx,vy=self.body:getLinearVelocity()



	if vx<self.velocidad or vy<self.velocidad then
		self.body:applyLinearImpulse(mx,my)
	end

	self.ox,self.oy=self.body:getX(),self.body:getY()
end

return bala