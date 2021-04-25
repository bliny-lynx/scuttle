 local lume = require("lume") local depth_accel = 0.2 local surfacing_speed = 2.5




 local types = {{["max-speed"] = 2.1, accel = 0.25, points = 1}, [3] = {["max-speed"] = 4, accel = 0.4, points = 10}, [5] = {["max-speed"] = 3, accel = 0.2, points = 25}}



 local function damage(enemy)
 enemy.hp = (enemy.hp - 1) return nil end

 local function make_enemy(x, y, sprite, hp)
 local type_values = types[hp]
 return {["fire-delay"] = 0, ["max-speed"] = type_values["max-speed"], accel = type_values.accel, damage = damage, depth = y, hp = hp, speedx = 0, speedy = 0, sprite = sprite, type = hp, worth = type_values.points, x = x} end












 local function alive_3f(enemy)
 return (enemy.hp > 0) end

 local function facing(enemy)

 if (0 >= enemy.speedx) then return "right" else return "left" end end



 local function update(enemy, dt, player, launch_bullet)

 local distance_to_player_squared = lume.distance(enemy.x, enemy.depth, player.xpos, player.depth, true)











































 if (5 < math.abs((player.depth - enemy.depth))) then if (player.depth > enemy.depth) then enemy.speedy = math.min(surfacing_speed, (enemy.speedy + depth_accel)) else enemy.speedy = math.max(( - surfacing_speed), (enemy.speedy - depth_accel)) end end if (1 <= lume.random(1, 2)) then if (player.xpos > enemy.x) then enemy.speedx = math.min(enemy["max-speed"], (enemy.speedx + enemy.accel)) else enemy.speedx = math.max(( - enemy["max-speed"]), (enemy.speedx - enemy.accel)) end end enemy.x = (enemy.x + enemy.speedx) enemy.depth = (enemy.depth + enemy.speedy) if (distance_to_player_squared < 1500) then player.alive = false end enemy["fire-delay"] = (enemy["fire-delay"] - dt) if ((distance_to_player_squared < 99000) and (enemy.type == 5) and (enemy["fire-delay"] < 0)) then enemy["fire-delay"] = 1.4 local multiplier if (enemy.x > player.xpos) then multiplier = -1 else multiplier = 1 end launch_bullet(enemy.x, enemy.depth, (multiplier * 5.1), lume.random(-1, 1)) end if (distance_to_player_squared > 20000000) then enemy.hp = 0 return nil end end return {["alive?"] = alive_3f, ["make-enemy"] = make_enemy, facing = facing, update = update}
