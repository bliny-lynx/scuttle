(local lume (require :lume))

(local depth-accel 0.2)
(local surfacing-speed 2.5)

(local types {1 {:accel 0.25 :max-speed 2.1 :points 1} ;; shark
              3 {:accel 0.4 :max-speed 4 :points 10} ;; ohka
              5 {:accel 0.2 :max-speed 3 :points 25}})

(fn damage [enemy]
  (set enemy.hp (- enemy.hp 1)))

(fn make-enemy [x y sprite hp]
  (let [type-values (. types hp)]
      {:x x
       :depth y
       :sprite sprite
       :accel (. type-values :accel)
       :max-speed (. type-values :max-speed)
       :damage damage
       :worth (. type-values :points)
       :type hp
       :fire-delay 0
       :hp hp
       :speedx 0
       :speedy 0}))

(fn alive? [enemy]
  (> enemy.hp 0))

(fn facing [enemy]
  ;; This is the wrong way around because I drew the shark facing left
  (if (>= 0 enemy.speedx)
      "right"
      "left"))

(fn update [enemy dt player launch-bullet]
  (let [distance-to-player-squared
        (lume.distance enemy.x enemy.depth player.xpos player.depth true)]
    (when (< 5 (math.abs (- player.depth enemy.depth)))
      (set enemy.speedy (if (> player.depth enemy.depth)
                            (math.min surfacing-speed (+ enemy.speedy depth-accel))
                            (math.max (- surfacing-speed) (- enemy.speedy depth-accel)))))
    (when (<= 1 (lume.random 1 2))
      (set enemy.speedx (if (> player.xpos enemy.x)
                            (math.min enemy.max-speed (+ enemy.speedx enemy.accel))
                            (math.max (- enemy.max-speed) (- enemy.speedx enemy.accel)))))
    (set enemy.x (+ enemy.x enemy.speedx))
    (set enemy.depth (+ enemy.depth enemy.speedy))

    (when (< distance-to-player-squared 1500)
      (set player.alive false))

    (set enemy.fire-delay (- enemy.fire-delay dt))
    (when (and (< distance-to-player-squared 99000)
               (= enemy.type 5)
               (< enemy.fire-delay 0))
      (set enemy.fire-delay 1.4)
      (let [multiplier (if (> enemy.x player.xpos) -1 1)]
        (launch-bullet enemy.x enemy.depth (* multiplier 5.1) (lume.random -1 1))))

    ;; despawn far away enemies
    (when (> distance-to-player-squared 20000000)
     (set enemy.hp 0))))

{:make-enemy make-enemy
 :alive? alive?
 :facing facing
 :update update}
