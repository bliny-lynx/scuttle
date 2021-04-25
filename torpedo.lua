 local lume = require("lume") local speed_ceiling = 10.0 local accel = 0.7 local fuse_time = 0.8





 local function make_torpedo(x, y, dir, speedy)
 return {["death-time"] = fuse_time, depth = y, direction = dir, speedx = 0, speedy = speedy, state = "primed", xpos = x} end







 local function facing(torpedo)
 return torpedo.direction end

 local function update(torpedo, dt, enemies, score)
 if (torpedo.direction == "left") then
 torpedo.speedx = math.max((torpedo.speedx - accel), ( - speed_ceiling)) elseif (torpedo.direction == "right") then

 torpedo.speedx = math.min((torpedo.speedx + accel), speed_ceiling) else
 error("invalid direction") end
 torpedo.xpos = (torpedo.xpos + torpedo.speedx)

























































 if (torpedo.depth <= 0) then torpedo.speedy = (torpedo.speedy + accel) end torpedo.depth = (torpedo.depth + torpedo.speedy) for _idx, enemy in ipairs(enemies) do if (lume.distance(torpedo.xpos, torpedo.depth, enemy.x, (enemy.depth + 20), true) < 1000) then enemy.damage(enemy) torpedo["death-time"] = 0 score.score = (score.score + enemy.worth) end end torpedo["death-time"] = (torpedo["death-time"] - dt) if (torpedo.state == "exploding") then torpedo.state = "dead" return nil elseif (not (torpedo.state == "dead") and (torpedo["death-time"] < 0)) then torpedo.state = "exploding" return nil end end local function alive_3f(torpedo) return not (torpedo.state == "dead") end return {["alive?"] = alive_3f, ["make-torpedo"] = make_torpedo, update = update}
