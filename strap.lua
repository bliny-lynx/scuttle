 local draw = require("draw")
 local color = require("color")
 local lib = require("lib")
 local player = require("player")
 local torpedo = require("torpedo")
 local bullet = require("bullet")
 local explosion = require("explosion")
 local enemy = require("enemy")

 local lume = require("lume") local timer = 0 local darkness = 0



 local timers = {["death-explosion-next"] = 0, ["emit-smoke"] = 0, ["enemy-spawn"] = 6}
 local score = {score = 0}
 local finsprites = {}
 local explosion_sprites = {}
 local shark_sprites = {}
 local ohka_sprites = {}
 local cthulhu_sprites = {}
 local torpedosprite = nil
 local bulletsprite = nil
 local smokesprite = nil

 local torpedo_sound = nil
 local ping_sound = nil
 local poof_sound = nil

 local translation = {0, 0}

 local directions = {"left", "right", "up", "down"}

 local fins = nil
 local torpedos = {}
 local bullets = {}
 local explosions = {}
 local enemies = {}
 local smoke_systems = {}

 local play_death local function _0_() poof_sound:seek(0) return poof_sound:play() end play_death = lume.once(_0_)



 local plrb = player["make-player"]()
 local smoke_particle_system = nil

 local function restart()
 enemies = {}
 torpedos = {}
 bullets = {}
 explosions = {} score.score = 0 timer = 0 darkness = 0



 local function _1_() poof_sound:seek(0) return poof_sound:play() end play_death = lume.once(_1_)


 plrb = player["make-player"]() timers["enemy-spawn"] = 4
 return nil end

 local function spawn_count_for_depth()
 local base_count
 if (plrb.depth > 6000) then
 base_count = lume.random(6, 12) elseif (plrb.depth > 4000) then

 base_count = lume.random(3, 7) elseif (plrb.depth > 3000) then


 base_count = lume.random(5, 10) elseif (plrb.depth > 2000) then


 base_count = lume.random(3, 7) else

 base_count = lume.random(4, 15) end
 local time_multiplier = lume.round((timer / 100))
 return lume.round((base_count * (time_multiplier + 1))) end

 local function enemy_for_depth(x, y)
 if (plrb.depth > 4000) then
 return enemy["make-enemy"](x, y, lib["make-sprite"](cthulhu_sprites, 0.4, timer), 5) elseif (plrb.depth > 2000) then

 return enemy["make-enemy"](x, y, lib["make-sprite"](ohka_sprites, 0.1, timer), 3) else
 return enemy["make-enemy"](x, y, lib["make-sprite"](shark_sprites, 0.3, timer), 1) end end

 local function spawn_enemies()
 local next_spawn = lume.random(5, 14)
 local spawn_count = spawn_count_for_depth()
 timers["enemy-spawn"] = (timers["enemy-spawn"] + next_spawn) ping_sound:play()

 for i = 1, spawn_count do
 local left_or_right = lume.randomchoice({-1, 1})
 local distance_x = (lume.random(700, 1200) * left_or_right)
 local distance_y = lume.random(-400, 1200)
 table.insert(enemies, enemy_for_depth((plrb.xpos + distance_x), (plrb.depth + distance_y))) end return nil end


 local function launch_bullet(x, y, velx, vely)
 return table.insert(bullets, bullet["make-bullet"](x, y, velx, vely)) end

 local function launch_torpedo()
 local facing = player.facing(plrb)
 local launch_offset = ({left = -120, right = 120})[facing]
 local launch_x = (plrb.xpos + launch_offset)
 local launch_y = (plrb.depth + 35)
 local launch_speed = (plrb.speedy / 2) if plrb.alive then torpedo_sound:seek(0) torpedo_sound:play()



 return table.insert(torpedos, torpedo["make-torpedo"](launch_x, launch_y, facing, launch_speed)) end end


 love.load = function()
 love.graphics.setDefaultFilter("nearest", "nearest")
 table.insert(finsprites, love.graphics.newImage("smalmarine1.png"))
 table.insert(finsprites, love.graphics.newImage("smalmarine2.png"))
 for _idx, pic in ipairs({"ex1.png", "ex2.png", "ex3.png", "ex4.png", "ex5.png", "ex6.png"}) do
 table.insert(explosion_sprites, love.graphics.newImage(pic)) end
 for _idx, pic in ipairs({"same1.png", "same2.png", "same3.png", "same4.png"}) do
 table.insert(shark_sprites, love.graphics.newImage(pic)) end
 for _idx, pic in ipairs({"ohka1.png", "ohka2.png", "ohka3.png", "ohka4.png", "ohka5.png", "ohka6.png", "ohka7.png", "ohka8.png"}) do

 table.insert(ohka_sprites, love.graphics.newImage(pic)) end
 for _idx, pic in ipairs({"cthulhu1.png", "cthulhu2.png"}) do
 table.insert(cthulhu_sprites, love.graphics.newImage(pic)) end
 torpedosprite = love.graphics.newImage("torpedo.png")
 bulletsprite = love.graphics.newImage("bullet.png")
 bullets = {}

 torpedo_sound = love.audio.newSource("woosh.ogg", "static")
 ping_sound = love.audio.newSource("ping.ogg", "static")
 poof_sound = love.audio.newSource("poof.ogg", "static")
 love.audio.setVolume(0.7)

 smokesprite = love.graphics.newImage("smokehuff.png")
 smoke_particle_system = love.graphics.newParticleSystem(smokesprite, 24) smoke_particle_system:setParticleLifetime(2, 5) smoke_particle_system:setLinearAcceleration(-20, -50, 20, -120) smoke_particle_system:setColors(1, 1, 1, 1, 1, 1, 1, 0) smoke_particle_system:setEmissionArea("normal", 10, 5)






 fins = lib["make-sprite"](finsprites, 0.2, timer) return nil end

 love.keypressed = function(key, scancode, isrepeat)
 if ((scancode == "x") and not isrepeat) then
 return launch_torpedo() elseif (scancode == "q") then

 return love.event.quit() elseif (key == "escape") then

 return restart() end end

 local function update_particles(dt)
 for _idx, system in ipairs(smoke_systems) do
 local particle_system = system.system particle_system:update(dt) end return nil end


 love.update = function(dt)
 timer = (timer + dt)
 lib.animate(fins, timer)

 update_particles(dt) if (timer > timers["emit-smoke"]) then local newsystem = smoke_particle_system:clone()


 timers["emit-smoke"] = (timer + lume.random(0.8, 1.45)) newsystem:start() newsystem:emit(lume.random(2, 4))


 table.insert(smoke_systems, {system = newsystem, x = plrb.xpos, y = plrb.depth}) end if (plrb.alive and (timer > timers["enemy-spawn"])) then


 spawn_enemies() end

 for _idx, key in ipairs(directions) do if love.keyboard.isDown(key) then

 player.impulse(plrb, key) end end
 player.update(plrb, dt) if (not plrb.alive and (timer > timers["death-explosion-next"])) then

 timers["death-explosion-next"] = (timer + 0.2)
 table.insert(explosions, explosion.create((plrb.xpos + lume.random(-20, 60)), (plrb.depth + lume.random(-20, 40)), lib["make-sprite"](explosion_sprites, 0.03, timer))) end



 for _idx, trp in ipairs(torpedos) do
 torpedo.update(trp, dt, enemies, score) if (trp.state == "exploding") then poof_sound:seek(0) poof_sound:play()



 table.insert(explosions, explosion.create(trp.xpos, trp.depth, lib["make-sprite"](explosion_sprites, 0.03, timer))) end end



 for _idx, blt in ipairs(bullets) do
 bullet.update(blt, plrb) if bullet.collided then

 play_death() end end
 for _idx, exp in ipairs(explosions) do
 explosion.update(exp, dt)
 lib.animate(exp.sprite, timer) end
 for _idx, enm in ipairs(enemies) do
 enemy.update(enm, dt, plrb, launch_bullet)
 lib.animate(enm.sprite, timer) end
 torpedos = lume.filter(torpedos, torpedo["alive?"])
 local function _4_(b) return b.alive end bullets = lume.filter(bullets, _4_)
 enemies = lume.filter(enemies, enemy["alive?"])
 explosions = lume.filter(explosions, explosion["alive?"])
 local function _5_(s)
 local p_system = s.system
 return (p_system:getCount() > 0) end smoke_systems = lume.filter(smoke_systems, _5_) return nil end

 local function draw_torpedos()
 for _idx, trp in ipairs(torpedos) do
 local rotate = ({left = math.pi, right = 0})[trp.direction]
 love.graphics.draw(torpedosprite, trp.xpos, trp.depth, rotate, 1, 1, 50, 25) end return nil end


 local function draw_bullets()
 for _idx, blt in ipairs(bullets) do
 love.graphics.draw(bulletsprite, blt.x, blt.y, 0, 1, 1, 12, 12) end return nil end


 local function draw_enemies()
 for _idx, enm in ipairs(enemies) do
 local factor_x = ({left = -1, right = 1})[enemy.facing(enm)]
 local enm_sprite = lib["current-sprite"](enm.sprite)
 love.graphics.draw(enm_sprite, enm.x, enm.depth, 0, factor_x, 1, 50, 25) end return nil end


 local function draw_explosions()
 for _idx, exp in ipairs(explosions) do
 love.graphics.draw(lib["current-sprite"](exp.sprite), exp.x, exp.y, exp.rotation, 2, 2, 25, 25) end return nil end


 local function draw_smoke_systems()
 for _idx, system in ipairs(smoke_systems) do
 love.graphics.draw(system.system, system.x, system.y) end return nil end

 local function draw_player()
 local factor_x = ({left = -1, right = 1})[player.facing(plrb)]
 local sprite = lib["current-sprite"](fins)
 return love.graphics.draw(sprite, plrb.xpos, plrb.depth, 0, factor_x, 1, 50, 25) end


 local function draw_surface(sine)
 love.graphics.setColor(1, 1, 1, 0.3)
 love.graphics.rectangle("fill", 0, 0, 800, (15 + translation[2] + (8 * sine)))


 love.graphics.setColor(color.yellow)
 love.graphics.print("Arrow keys to move, X to fire torpedoes", 100, lume.round(((translation[2] - 60) + (4 * sine))))

 return love.graphics.print("Go deeper and find more valuable enemies!", 100, lume.round(((translation[2] - 30) + (4 * sine)))) end


 local function draw_info()
 love.graphics.setColor(1, 1, 1)
 love.graphics.print(("Depth " .. lume.round((plrb.depth / 10))), 0, 0)
 return love.graphics.print(("Score " .. score.score), 0, 20) end

 local function print_death_message()
 love.graphics.setColor(color.yellow)
 love.graphics.print("GAME OVER", 200, 150, 0, 2, 2)
 love.graphics.print(("Final score " .. tostring(score.score)), 200, 250, 0, 2, 2)
 love.graphics.print("Thank you for playing!", 200, 350, 0, 2, 2)
 return love.graphics.print("Press ESC to try again or Q to quit", 200, 450, 0, 2, 2) end

 local function draw_death_screen()
 do local color_value = (1 - darkness)
 love.graphics.setColor(0, 0, 0, darkness)
 love.graphics.rectangle("fill", 0, 0, 800, 800) end
 if (darkness < 1) then
 darkness = (darkness + 0.01) return nil else
 return print_death_message() end end

 love.draw = function()
 local timer_sine = math.sin(timer)
 translation = player["get-translation"](plrb, translation[1], translation[2])
 love.graphics.clear(color.background)
 love.graphics.push()
 love.graphics.setColor(1, 1, 1)
 love.graphics.translate(translation[1], translation[2])
 draw_torpedos()
 draw_bullets()
 draw_enemies()
 draw_player()
 draw_smoke_systems()
 draw_explosions()
 love.graphics.pop()
 love.graphics.origin() if (plrb.depth < 600) then

 draw_surface(timer_sine) end
 draw_info() if not plrb.alive then

 return draw_death_screen() end end return love.draw
