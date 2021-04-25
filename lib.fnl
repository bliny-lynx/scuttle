(local lume (require :lume))

(fn cycle [sprite]
  (let [len (length sprite.sprites)]
    (if (= sprite.idx len)
        1
        (+ 1 sprite.idx))))

(lambda make-sprite [sprites anim-timeout timer]
  {:sprites sprites
   :idx 1 
   :next-timeout (+ timer anim-timeout)
   :default-timeout anim-timeout})

(fn current-sprite [sprite]
  (. sprite.sprites sprite.idx))

(fn animate [sprite timer]
  (when (> timer sprite.next-timeout)
    (set sprite.idx (cycle sprite))
    (set sprite.next-timeout (+ sprite.next-timeout
                                sprite.default-timeout))))

{:make-sprite make-sprite
 :animate animate
 :current-sprite current-sprite}
