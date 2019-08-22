local Class  = require "libs.hump.class"
local sti = require "libs.sti.sti"
local jugador = require "entidades.jugador"

local juego ={}

function juego:init()

end

function juego:enter()
	self.gameobject={}
	self.gameobject.jugadores={}
	self.gameobject.enemigos={}
	self.gameobject.balas={}

	self.sprites_todos = require "assets.img.img"


	self.world = love.physics.newWorld( 0, 0, true )

	self.map = sti("assets/mapas/mapa.lua")
	self:leer_mapa()
	self:crear_capas()



end

function juego:update(dt)
	self.world:update(dt)
	self.map:update(dt)
end

function juego:draw()
	self.map:draw()
	draw_fisicas(self.world)
end

function juego:keypressed(key)
	if self.gameobject.jugadores[1] then
		self.gameobject.jugadores[1]:keypressed(key)
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

	end
end

return juego