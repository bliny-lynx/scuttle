{
 :ellipse (fn [mode x y dx dy r]
  (love.graphics.rotate r)
  (love.graphics.ellipse mode x y dx dy)
  (love.graphics.origin))
}
