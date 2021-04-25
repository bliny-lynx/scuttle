(local lume (require :lume))

(fn create [x y sprite]
  {:x x
   :y y
   :sprite sprite
   :rotation (lume.random (* 2 math.pi))
   :death-time (* sprite.default-timeout (length sprite.sprites))})

(fn update [exp dt]
  (set exp.death-time (- exp.death-time dt)))

(fn alive? [exp]
  (> exp.death-time 0))

{:create create
 :update update
 :alive? alive?}
