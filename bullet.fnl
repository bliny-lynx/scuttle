(local lume (require :lume))

(fn update [bullet player]
  (set bullet.x (+ bullet.x bullet.velx))
  (set bullet.y (+ bullet.y bullet.vely))
  (let [distance-to-player-squared
        (lume.distance bullet.x bullet.y player.xpos player.depth true)]
    (if (> distance-to-player-squared 10000000)
        (set bullet.alive false))
    (when (< distance-to-player-squared 1300)
      (set player.alive false)
      (set bullet.collided true))))

(fn make-bullet [x y velx vely]
  {:x x
   :y y
   :velx velx
   :vely vely
   :alive true
   :collided false})

{:make-bullet make-bullet
 :update update}
