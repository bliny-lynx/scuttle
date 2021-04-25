
 local function _0_(mode, x, y, dx, dy, r)
 love.graphics.rotate(r)
 love.graphics.ellipse(mode, x, y, dx, dy)
 return love.graphics.origin() end return {ellipse = _0_}
