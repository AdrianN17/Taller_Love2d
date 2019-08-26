local sound = {}

sound.fondo=  love.audio.newSource("assets/sound/fondo.ogg","stream")

sound.fondo:setLooping(true)

sound.canon = love.audio.newSource("assets/sound/canon.ogg","static")
sound.canon:setPitch(0.5)


return sound