local sti = require "libs.sti.sti"
local map 


function love.load()
	map = sti("assets/mapas/mapa.lua")
	leer_mapa()
	crear_capas()
end

function love.draw()
	map:draw()
end

function love.update(dt)
	map:update(dt)
end

function leer_mapa()

  for _, layer in ipairs(map.layers) do
    if layer.type=="tilelayer" then
      get_tile(layer)
    elseif layer.type=="objectgroup" then
      get_objects(layer)
    end
  end
  
  map:removeLayer("Borrador")
  
end


function get_objects(objectlayer)
  
    for _, obj in pairs(objectlayer.objects) do
      if obj.name then
        if obj.name == "Player" then
        	
        end
      end
    end
end

function get_tile(layer)
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
end

function crear_capas()
	local Balas_layers = map:addCustomLayer("Balas",3)
	local Enemigos_layers = map:addCustomLayer("Enemigos",4)
	local Jugador_layers = map:addCustomLayer("Jugadores",5)

	--draw

	Balas_layers.draw = function(obj)
		
	end

	Enemigos_layers.draw = function(obj)
		
	end

	Jugador_layers.draw = function(obj)
		
	end

	--update

	Balas_layers.update = function(obj,dt)
		
	end

	Enemigos_layers.update = function(obj,dt)
		
	end

	Jugador_layers.update = function(obj,dt)
		
	end
end
