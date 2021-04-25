(local lume (require :lume))

(local speed-ceiling 10.0)
(local accel 0.7)
(local fuse-time 0.8)

(fn make-torpedo [x y dir speedy]
  {:speedx 0
   :speedy speedy
   :direction dir
   :depth y
   :xpos x
   :death-time fuse-time
   :state "primed"})

(fn facing [torpedo]
  torpedo.direction)

(fn update [torpedo dt enemies score]
  (if (= torpedo.direction "left")
      (set torpedo.speedx (math.max (- torpedo.speedx accel) (- speed-ceiling)))
      (= torpedo.direction "right")
      (set torpedo.speedx (math.min (+ torpedo.speedx accel) speed-ceiling))
      (error "invalid direction"))
  (set torpedo.xpos (+ torpedo.xpos torpedo.speedx))
  (when (<= torpedo.depth 0)
    (set torpedo.speedy (+ torpedo.speedy accel)))
  (set torpedo.depth (+ torpedo.depth torpedo.speedy))
  (each [_idx enemy (ipairs enemies)]
    (when (< (lume.distance torpedo.xpos torpedo.depth enemy.x (+ enemy.depth 20) true) 1000)
      (enemy.damage enemy)
      (set torpedo.death-time 0)
      (set score.score (+ score.score enemy.worth))))
  (set torpedo.death-time (- torpedo.death-time dt))
  (if (= torpedo.state "exploding")
      (set torpedo.state "dead")
      (and (not (= torpedo.state "dead")) (< torpedo.death-time 0))
      (set torpedo.state "exploding")))

(fn alive? [torpedo]
  (not (= torpedo.state "dead")))

{:make-torpedo make-torpedo
 :update update
 :alive? alive?}
