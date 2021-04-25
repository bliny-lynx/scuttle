 local lume = require("lume")


 do local _ = {depth = 0, speedx = 0, speedy = 0, xpos = 123} end local speed_ceiling = 8 local surfacing_speed = 3.6 local accel = 0.6 local gravity = 0.7








 local dampen_factor = (accel / 6)

 local function make_player()
 return {alive = true, depth = 3, speedx = 1e-06, speedy = 0, xpos = 123} end





 local function impulse(player, dir)
 if (dir == "left") then

 player.speedx = math.max((player.speedx - accel), ( - speed_ceiling)) elseif (dir == "right") then


 player.speedx = math.min((player.speedx + accel), speed_ceiling) elseif (dir == "up") then


 if (player.depth > 0) then
 player.speedy = math.max((player.speedy - accel), ( - surfacing_speed)) else
 player.speedy = player.speedy end elseif (dir == "down") then



 player.speedy = math.min((player.speedy + accel), surfacing_speed) else
 error("invalid direction") end












































 if not player.alive then player.speedx = 0 player.speedy = 0 return nil end end local function damp(player) if (player.depth <= 0) then player.speedy = (player.speedy + gravity) end if (player.speedx > dampen_factor) then player.speedx = (player.speedx - dampen_factor) return nil elseif (player.speedx < ( - dampen_factor)) then player.speedx = (player.speedx + dampen_factor) return nil elseif (player.speedy > dampen_factor) then player.speedy = (player.speedy - dampen_factor) return nil elseif (player.speedy < ( - dampen_factor)) then player.speedy = (player.speedy + dampen_factor) return nil end end local function facing(player) if (0 >= player.speedx) then return "left" else return "right" end end local function get_translation(player, x, y) local function translate(position, translation, threshold, screen_dimension) local apparent_position = (position + translation) local min_side = threshold local max_side = (screen_dimension - threshold) if (apparent_position < min_side) then return (translation + (min_side - apparent_position)) elseif (apparent_position > max_side) then return (translation - (apparent_position - max_side)) else return translation end end return {lume.round(translate(player.xpos, x, 200, 800)), lume.round(translate(player.depth, y, 220, 600))} end local function update(player, dt) damp(player) player.xpos = (player.xpos + player.speedx) player.depth = (player.depth + player.speedy) return nil end return {["get-translation"] = get_translation, ["make-player"] = make_player, facing = facing, impulse = impulse, update = update}
