(local draw (require :draw))
(local color (require :color))
(local lib (require :lib))
(local player (require :player))
(local torpedo (require :torpedo))
(local bullet (require :bullet))
(local explosion (require :explosion))
(local enemy (require :enemy))

(local lume (require :lume))

(var timer 0)
(var darkness 0)
(local timers {:emit-smoke 0 :enemy-spawn 6 :death-explosion-next 0})
(local score {:score 0})
(local finsprites [])
(local explosion-sprites [])
(local shark-sprites [])
(local ohka-sprites [])
(local cthulhu-sprites [])
(var torpedosprite nil)
(var bulletsprite nil)
(var smokesprite nil)

(var torpedo-sound nil)
(var ping-sound nil)
(var poof-sound nil)

(var translation [0 0])

(local directions ["left" "right" "up" "down"])

(var fins nil)
(var torpedos [])
(var bullets [])
(var explosions [])
(var enemies [])
(var smoke-systems [])

(var play-death (lume.once (fn []
                             (poof-sound:seek 0)
                             (poof-sound:play))))

(var plrb (player.make-player))
(var smoke-particle-system nil)

(fn restart []
  (set enemies [])
  (set torpedos [])
  (set bullets [])
  (set explosions [])
  (set score.score 0)
  (set timer 0)
  (set darkness 0)
  (set play-death (lume.once (fn []
                               (poof-sound:seek 0)
                               (poof-sound:play))))
  (set plrb (player.make-player))
  (set timers.enemy-spawn 4))

(fn spawn-count-for-depth []
  (let
      [base-count (if (> plrb.depth 6000)
                      (lume.random 6 12)
                      (> plrb.depth 4000)
                      (lume.random 3 7)
                      (> plrb.depth 3000)
                      ;; ohkas but deeper
                      (lume.random 5 10)
                      (> plrb.depth 2000)
                      ;; ohkas
                      (lume.random 3 7)
                      ;; sharks
                      (lume.random 4 15))
       time-multiplier (lume.round (/ timer 100))]
    (lume.round (* base-count (+ time-multiplier 1)))))

(fn enemy-for-depth [x y]
  (if (> plrb.depth 4000)
      (enemy.make-enemy x y (lib.make-sprite cthulhu-sprites 0.4 timer) 5)
      (> plrb.depth 2000)
      (enemy.make-enemy x y (lib.make-sprite ohka-sprites 0.1 timer) 3)
      (enemy.make-enemy x y (lib.make-sprite shark-sprites 0.3 timer) 1)))

(fn spawn-enemies []
  (let [next-spawn (lume.random 5 14)
        spawn-count (spawn-count-for-depth)]
    (set timers.enemy-spawn (+ timers.enemy-spawn next-spawn))
    (ping-sound:play)
    (for [i 1 spawn-count]
      (let [left-or-right (lume.randomchoice [-1 1])
            distance-x (* (lume.random 700 1200) left-or-right)
            distance-y (lume.random -400 1200)]
        (table.insert enemies (enemy-for-depth (+ plrb.xpos distance-x)
                                               (+ plrb.depth distance-y)))))))

(fn launch-bullet [x y velx vely]
  (table.insert bullets (bullet.make-bullet x y velx vely)))

(fn launch-torpedo []
  (let [facing (player.facing plrb)
        launch-offset (. {"right" 120 "left" -120} facing)
        launch-x (+ plrb.xpos launch-offset)
        launch-y (+ plrb.depth 35)
        launch-speed (/ plrb.speedy 2)]
    (when plrb.alive
      (torpedo-sound:seek 0)
      (torpedo-sound:play)
      (table.insert torpedos (torpedo.make-torpedo launch-x launch-y
                                                   facing launch-speed)))))

(fn love.load []
  (love.graphics.setDefaultFilter "nearest" "nearest")
  (table.insert finsprites (love.graphics.newImage "smalmarine1.png"))
  (table.insert finsprites (love.graphics.newImage "smalmarine2.png"))
  (each [_idx pic (ipairs ["ex1.png" "ex2.png" "ex3.png" "ex4.png" "ex5.png" "ex6.png"])]
    (table.insert explosion-sprites (love.graphics.newImage pic)))
  (each [_idx pic (ipairs ["same1.png" "same2.png" "same3.png" "same4.png"])]
    (table.insert shark-sprites (love.graphics.newImage pic)))
  (each [_idx pic (ipairs ["ohka1.png" "ohka2.png" "ohka3.png" "ohka4.png" "ohka5.png"
                           "ohka6.png" "ohka7.png" "ohka8.png"])]
    (table.insert ohka-sprites (love.graphics.newImage pic)))
  (each [_idx pic (ipairs ["cthulhu1.png" "cthulhu2.png"])]
    (table.insert cthulhu-sprites (love.graphics.newImage pic)))
  (set torpedosprite (love.graphics.newImage "torpedo.png"))
  (set bulletsprite (love.graphics.newImage "bullet.png"))
  (set bullets [])

  (set torpedo-sound (love.audio.newSource "woosh.ogg" "static"))
  (set ping-sound (love.audio.newSource "ping.ogg" "static"))
  (set poof-sound (love.audio.newSource "poof.ogg" "static"))
  (love.audio.setVolume 0.7)
  
  (set smokesprite (love.graphics.newImage "smokehuff.png"))
  (set smoke-particle-system (love.graphics.newParticleSystem smokesprite 24))
  (smoke-particle-system:setParticleLifetime 2 5)
  (smoke-particle-system:setLinearAcceleration -20 -50 20 -120)
  (smoke-particle-system:setColors 1 1 1 1
                                   1 1 1 0)
  (smoke-particle-system:setEmissionArea "normal" 10 5)

  (set fins (lib.make-sprite finsprites 0.2 timer)))

(fn love.keypressed [key scancode isrepeat]
  (if (and (= scancode "x") (not isrepeat))
      (launch-torpedo)
      (= scancode "q")
      (love.event.quit)
      (= key "escape")
      (restart)))

(fn update-particles [dt]
  (each [_idx system (ipairs smoke-systems)]
    (let [particle-system (. system :system)]
      (particle-system:update dt))))

(fn love.update [dt]
  (set timer (+ timer dt))
  (lib.animate fins timer)

  (update-particles dt)
  (when (> timer timers.emit-smoke)
    (let [newsystem (smoke-particle-system:clone)]
      (set timers.emit-smoke (+ timer (lume.random 0.8 1.45)))
      (newsystem:start)
      (newsystem:emit (lume.random 2 4))
      (table.insert smoke-systems {:system newsystem :x plrb.xpos :y plrb.depth})))

  (when (and plrb.alive (> timer timers.enemy-spawn))
    (spawn-enemies))

  (each [_idx key (ipairs directions)]
    (when (love.keyboard.isDown key)
      (player.impulse plrb key)))
  (player.update plrb dt)
  (when (and (not plrb.alive) (> timer timers.death-explosion-next))
    (set timers.death-explosion-next (+ timer 0.2))
    (table.insert explosions
                  (explosion.create (+ plrb.xpos (lume.random -20 60))
                                    (+ plrb.depth (lume.random -20 40))
                                    (lib.make-sprite explosion-sprites 0.03 timer))))
  (each [_idx trp (ipairs torpedos)]
    (torpedo.update trp dt enemies score)
    (when (= trp.state "exploding")
      (poof-sound:seek 0)
      (poof-sound:play)
      (table.insert explosions
                    (explosion.create trp.xpos trp.depth
                                      (lib.make-sprite explosion-sprites 0.03 timer)))))

  (each [_idx blt (ipairs bullets)]
    (bullet.update blt plrb)
    (when bullet.collided
      (play-death)))
  (each [_idx exp (ipairs explosions)]
    (explosion.update exp dt)
    (lib.animate exp.sprite timer))
  (each [_idx enm (ipairs enemies)]
    (enemy.update enm dt plrb launch-bullet)
    (lib.animate enm.sprite timer))
  (set torpedos (lume.filter torpedos torpedo.alive?))
  (set bullets (lume.filter bullets (fn [b] b.alive)))
  (set enemies (lume.filter enemies enemy.alive?))
  (set explosions (lume.filter explosions explosion.alive?))
  (set smoke-systems (lume.filter smoke-systems (fn [s]
                                                  (let [p-system (. s :system)]
                                                    (> (p-system:getCount) 0))))))

(fn draw-torpedos []
  (each [_idx trp (ipairs torpedos)]
    (let [rotate (. {"left" math.pi "right" 0} trp.direction)]
        (love.graphics.draw torpedosprite trp.xpos trp.depth
                         rotate 1 1 50 25))))

(fn draw-bullets []
  (each [_idx blt (ipairs bullets)]
    (love.graphics.draw bulletsprite blt.x blt.y
                        0 1 1 12 12)))

(fn draw-enemies []
  (each [_idx enm (ipairs enemies)]
    (let [factor-x (. {"left" -1 "right" 1} (enemy.facing enm))
          enm-sprite (lib.current-sprite enm.sprite)]
        (love.graphics.draw enm-sprite enm.x enm.depth
                         0 factor-x 1 50 25))))

(fn draw-explosions []
  (each [_idx exp (ipairs explosions)]
    (love.graphics.draw (lib.current-sprite exp.sprite)
                        exp.x exp.y exp.rotation 2 2 25 25)))

(fn draw-smoke-systems []
  (each [_idx system (ipairs smoke-systems)]
    (love.graphics.draw system.system system.x system.y)))

(fn draw-player []
  (let [factor-x (. {"left" -1 "right" 1} (player.facing plrb))
        sprite (lib.current-sprite fins)]
    (love.graphics.draw sprite plrb.xpos plrb.depth
                        0 factor-x 1 50 25)))

(fn draw-surface [sine]
  (love.graphics.setColor 1 1 1 0.3)
  (love.graphics.rectangle "fill"
                           0 0
                           800 (+ 15 (. translation 2) (* 8 sine)))
  (love.graphics.setColor color.yellow)
  (love.graphics.print "Arrow keys to move, X to fire torpedoes"
                       100 (lume.round (+ (- (. translation 2) 60) (* 4 sine))))
  (love.graphics.print "Go deeper and find more valuable enemies!"
                       100 (lume.round (+ (- (. translation 2) 30) (* 4 sine)))))

(fn draw-info []
  (love.graphics.setColor 1 1 1)
  (love.graphics.print (.. "Depth " (lume.round (/ plrb.depth 10))) 0 0)
  (love.graphics.print (.. "Score " score.score) 0 20))

(fn print-death-message []
  (love.graphics.setColor color.yellow)
  (love.graphics.print "GAME OVER" 200 150 0 2 2)
  (love.graphics.print (.. "Final score " (tostring score.score)) 200 250 0 2 2)
  (love.graphics.print "Thank you for playing!" 200 350 0 2 2)
  (love.graphics.print "Press ESC to try again or Q to quit" 200 450 0 2 2))

(fn draw-death-screen []
  (let [color-value (- 1 darkness)]
    (love.graphics.setColor 0 0 0 darkness)
    (love.graphics.rectangle "fill" 0 0 800 800))
  (if (< darkness 1)
      (set darkness (+ darkness 0.01))
      (print-death-message)))

(fn love.draw []
  (let [timer-sine (math.sin timer)]
    (set translation (player.get-translation plrb (. translation 1) (. translation 2)))
    (love.graphics.clear color.background)
    (love.graphics.push)
    (love.graphics.setColor 1 1 1)
    (love.graphics.translate (. translation 1) (. translation 2))
    (draw-torpedos)
    (draw-bullets)
    (draw-enemies)
    (draw-player)
    (draw-smoke-systems)
    (draw-explosions)
    (love.graphics.pop)
    (love.graphics.origin)
    (when (< plrb.depth 600)
      (draw-surface timer-sine))
    (draw-info)
    (when (not plrb.alive)
      (draw-death-screen))))


