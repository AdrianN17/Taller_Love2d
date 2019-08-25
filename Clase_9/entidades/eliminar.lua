local Class  = require "libs.hump.class"

local eliminar = Class{}

function eliminar:init(tabla_principal)
	self.tabla_principal=tabla_principal
end

function eliminar:remover()
	self.body:destroy()
	self.entidad:eliminar_objeto(self,self.tabla_principal)
end

return eliminar