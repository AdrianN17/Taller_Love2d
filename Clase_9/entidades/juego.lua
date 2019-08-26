local Class  = require "libs.hump.class"
local sti = require "libs.sti.sti"
local gamera = require "libs.gamera.gamera"

local jugador = require "entidades.jugador"
local enemigo = require "entidades.enemigo"

local pausa = require "escenas.pausa"

local serialize = require "libs.ser.ser"

local juego ={}

function juego:init()

	self.sprites_todos = require "assets.img.img"
	self.sonidos_todos = require "assets.sound.sound"

end

function juego:enter()
	self.gameobject={}
	self.gameobject.jugadores={}
	self.gameobject.enemigos={}
	self.gameobject.balas={}

	


	self.world = love.physics.newWorld( 0, 0, true )

	self.map = sti("assets/mapas/mapa.lua")

	local x,y=love.graphics.getDimensions( )

	self.map:resize(x,y)
	self.cam = gamera.new(0,0,self.map.width*self.map.tilewidth, self.map.height*self.map.tileheight)
  
	self.cam:setWindow(0,0,x,y)

	self.world:setCallbacks(self:callbacks())

	
	self:leer_mapa()
	self:crear_capas()

	self:cerrar_mapa()

	self.contador_enemigos=0
	self.max_contador_enemigos=5


	--sonido 

	self.sonidos_todos.fondo:play()

	--score

	self.score=0
end

function juego:update(dt)
	self.world:update(dt)
	self.map:update(dt)

	if self.gameobject.jugadores[1] then
		local player = self.gameobject.jugadores[1]
		self.cam:setPosition(player.ox, player.oy)
	end

	self.contador_enemigos=self.contador_enemigos+dt

	if self.contador_enemigos> self.max_contador_enemigos then
		enemigo(self,750,love.math.random(1,9)*100)

		self.contador_enemigos=0
	end
end

function juego:draw()
	local cx,cy,cw,ch=self.cam:getVisible()
  	self.map:draw(-cx,-cy,1,1)

  	--[[self.cam:draw(function(l,t,w,h)
 		draw_fisicas(self.world)
	end)]]

	love.graphics.print("Mi score : " .. self.score,650,10)

end

function juego:keypressed(key)
	if self.gameobject.jugadores[1] then
		self.gameobject.jugadores[1]:keypressed(key)

		if key=="p" then
			Gamestate.push(pausa)
		end
	else
		if key=="return" then
			self:limpiar()
			Gamestate.switch(menu)
		end
	end
end

function juego:keyreleased(key)
	if self.gameobject.jugadores[1] then
		self.gameobject.jugadores[1]:keyreleased(key)
	end
end

function juego:mousepressed(x,y,button)
	if self.gameobject.jugadores[1] then
		self.gameobject.jugadores[1]:mousepressed(x,y,button)
	end
end

function juego:mousereleased(x,y,button)
	if self.gameobject.jugadores[1] then
		self.gameobject.jugadores[1]:mousereleased(x,y,button)
	end
end

function juego:leer_mapa()

  for _, layer in ipairs(self.map.layers) do
    if layer.type=="tilelayer" then
      self:get_tile(layer)
    elseif layer.type=="objectgroup" then
      self:get_objects(layer)
    end
  end
  
  self.map:removeLayer("Borrador")
  
end


function juego:get_objects(objectlayer)
  
    for _, obj in pairs(objectlayer.objects) do
      if obj.name then
        if obj.name == "Player" then
        	jugador(self,obj.x,obj.y)
        end
      end
    end
end

function juego:get_tile(layer)
    local lista_paredes = {}
    for y=1, layer.height,1 do
      for x=1, layer.width,1 do
        local tile = layer.data[y][x]

        if tile then
          if tile.properties.collidable then
              local ox,oy = (x-1),(y-1)
              local t = {x=ox*32,y=oy*32,w=32,h=32}

              table.insert(lista_paredes,t)
          end
        end
      end
    end

    if #lista_paredes>0 then
    	self:crear_paredes(lista_paredes)
    end
end

function juego:crear_capas()
	local Balas_layers = self.map:addCustomLayer("Balas",3)
	local Enemigos_layers = self.map:addCustomLayer("Enemigos",4)
	local Jugador_layers = self.map:addCustomLayer("Jugadores",5)

	--draw

	Balas_layers.draw = function(obj)
		for _,object_data in ipairs(self.gameobject.balas) do
			object_data:draw()
		end
	end

	Enemigos_layers.draw = function(obj)
		for _,object_data in ipairs(self.gameobject.enemigos) do
			object_data:draw()
		end
	end

	Jugador_layers.draw = function(obj)
		for _,object_data in ipairs(self.gameobject.jugadores) do
			object_data:draw()
		end
	end

	--update

	Balas_layers.update = function(obj,dt)
		for _,object_data in ipairs(self.gameobject.balas) do
			object_data:update(dt)
		end
	end

	Enemigos_layers.update = function(obj,dt)
		for _,object_data in ipairs(self.gameobject.enemigos) do
			object_data:update(dt)
		end
	end

	Jugador_layers.update = function(obj,dt)
		for _,object_data in ipairs(self.gameobject.jugadores) do
			object_data:update(dt)
		end
	end
end

function juego:nuevo_objeto(obj,nombre_tabla)
	table.insert(self.gameobject[nombre_tabla], obj)
end

function juego:eliminar_objeto(obj,nombre_tabla)
	for i, objeto in ipairs(self.gameobject[nombre_tabla]) do
		if objeto == obj then
			table.remove(self.gameobject[nombre_tabla],i)
			return
		end
	end
end

function juego:crear_paredes(lista)
	self.body=love.physics.newBody(self.world,0,0,"kinematic")

	for _,tile in ipairs(lista) do

		local x,y,w,h=tile.x,tile.y,tile.w,tile.h
		local shape=love.physics.newRectangleShape(x+w/2,y+h/2,w,h)
		local fixture=love.physics.newFixture(self.body,shape)

		fixture:setUserData( {data="solido", pos=4} )

	end


end

function juego:getxy()
	local cx,cy = self.cam:toWorld(love.mouse.getX(),love.mouse.getY())
	return cx,cy
end

function juego:callbacks()

	local beginContact =  function(a, b, coll)

		local obj1=nil
 		local obj2=nil

		local o1,o2=a:getUserData(),b:getUserData()

		if o1.pos<o2.pos then
			obj1=o1
			obj2=o2
		else
			obj1=o2
			obj2=o1
		end

 		local x,y=coll:getNormal()

 		if obj1.data == "balas" and obj2.data == "solido" then
 			obj1.obj:remover()
 		elseif obj1.data == "enemigos" and obj2.data == "balas" then
 			--receptor dano
 			self:dano(obj1.obj,1)
 			obj2.obj:remover()
 			
 		elseif obj1.data=="personajes" and obj2.data == "balas" then
 			--receptor dano
 			self:dano(obj1.obj,1)
 			obj2.obj:remover()
 		elseif obj1.data == "personajes" and obj2.data=="enemigos_vision" then
 			obj2.obj.estados:atacando()
 			obj2.obj.blanco = obj1.obj
 		elseif obj1.data == "enemigos" and obj2.data == "solido" then
 			obj1.obj.toco_pared=true
 		end


 	end
  
	local endContact =  function(a, b, coll)
		local obj1=nil
		local obj2=nil

		local o1,o2=a:getUserData(),b:getUserData()
	  
	if o1.pos<o2.pos then
			obj1=o1
			obj2=o2
		else
			obj1=o2
			obj2=o1
		end

		local x,y=coll:getNormal()

		if obj1.data == "personajes" and obj2.data=="enemigos_vision" then
			obj2.obj.estados:buscando()
			obj2.obj.blanco = nil
		end

	end
  
	local preSolve =  function(a, b, coll)
	    
	end
  
  	local postSolve =  function(a, b, coll, normalimpulse, tangentimpulse)

	end

	return beginContact,endContact,preSolve,postSolve
end

function juego:cerrar_mapa()
  local w,h=self.map.width*self.map.tilewidth, self.map.height*self.map.tileheight
  local cerca = {}
  cerca.body=love.physics.newBody(self.world,0,0,"static")
  cerca.shape=love.physics.newChainShape(true,0,0,w,0,h,w,0,h)
  cerca.fixture=love.physics.newFixture(cerca.body,cerca.shape)
  
  cerca.fixture:setUserData( {data="solido", pos=4} )

end

function juego:dano(obj,dano)
	obj.hp=obj.hp-dano
end

function juego:limpiar()
	self.score=0
	self.sonidos_todos.fondo:stop()

	self.gameobject={}
	self.world:destroy()
end

function juego:guardar_score()
	if love.filesystem.getInfo("score.lua") then
		local old_data=love.filesystem.load("score.lua")()

		if old_data.score<self.score then
			love.filesystem.write("score.lua",serialize({score=self.score}))
		end
	end
end


return juego