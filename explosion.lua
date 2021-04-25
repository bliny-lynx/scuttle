 local lume = require("lume")

 local function create(x, y, sprite)
 return {["death-time"] = (sprite["default-timeout"] * #sprite.sprites), rotation = lume.random((2 * math.pi)), sprite = sprite, x = x, y = y} end





 local function update(exp, dt)
 exp["death-time"] = (exp["death-time"] - dt) return nil end

 local function alive_3f(exp)
 return (exp["death-time"] > 0) end

 return {["alive?"] = alive_3f, create = create, update = update}
