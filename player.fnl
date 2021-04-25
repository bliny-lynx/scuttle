(local lume (require :lume))

;; sample player
{:speedx 0
 :speedy 0
 :depth 0
 :xpos 123}

(local speed-ceiling 8)
(local surfacing-speed 3.6)
(local accel 0.6)
(local gravity 0.7)
(local dampen-factor (/ accel 6))

(fn make-player []
  {:speedx 0.000001
   :speedy 0
   :depth 3
   :xpos 123
   :alive true})

(fn impulse [player dir]
  (if (= dir "left")
      (set player.speedx
           (math.max (- player.speedx accel) (- speed-ceiling)))
      (= dir "right")
      (set player.speedx
           (math.min (+ player.speedx accel) speed-ceiling))
      (= dir "up")
      (set player.speedy
           (if (> player.depth 0)
               (math.max (- player.speedy accel) (- surfacing-speed))
               player.speedy)
           )
      (= dir "down")
      (set player.speedy
           (math.min (+ player.speedy accel) surfacing-speed))
      (error "invalid direction"))
  (when (not player.alive)
    (set player.speedx 0)
    (set player.speedy 0)))

(fn damp [player]
  (when (<= player.depth 0)
      (set player.speedy (+ player.speedy gravity)))
  (if (> player.speedx dampen-factor)
      (set player.speedx (- player.speedx dampen-factor))
      (< player.speedx (- dampen-factor))
      (set player.speedx (+ player.speedx dampen-factor))
      (> player.speedy dampen-factor)
      (set player.speedy (- player.speedy dampen-factor))
      (< player.speedy (- dampen-factor))
      (set player.speedy (+ player.speedy dampen-factor))))

(fn facing [player]
  (if (>= 0 player.speedx)
      "left"
      "right"))

(fn get-translation [player x y]
  (fn translate [position translation threshold screen-dimension]
    (let [apparent-position (+ position translation)
          min-side threshold
          max-side (- screen-dimension threshold)]
      (if (< apparent-position min-side)
          (+ translation (- min-side apparent-position))
          (> apparent-position max-side)
          (- translation (- apparent-position max-side))
          translation)))
  [(lume.round (translate player.xpos x 200 800))
   (lume.round (translate player.depth y 220 600))])

(fn update [player dt]
  (damp player)
  (set player.xpos (+ player.xpos player.speedx))
  (set player.depth (+ player.depth player.speedy)))

{:make-player make-player
 :facing facing
 :impulse impulse
 :update update
 :get-translation get-translation}
