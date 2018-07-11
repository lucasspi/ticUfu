#lang racket/gui

(require 2htdp/image)
(require 2htdp/universe)

(require "tic-tac-toe.rkt")

(define window-side 600)
(define tile-side (/ window-side 3))
(define tile-fill-ratio 0.8)

(define default-thickness 3)
(define default-O-color 'Seagreen)
(define default-X-color 'Cornflowerblue)
(define default-line-color 'Maroon)
(define default-O-pen (make-pen default-O-color default-thickness "solid" "butt" "round"))
(define default-X-pen (make-pen default-X-color default-thickness "solid" "butt" "round"))
(define default-line-pen (make-pen default-line-color default-thickness "solid" "butt" "round"))

(define (process-button-down world-state x y)
  (let ([index (index-from-mouse-click x y)])
    (if (empty? (vector-ref (game-state world-state) index))
      (game (vector-copy-and-replace (game-state world-state) index 'X))
      world-state)))

(define (process-mouse world-state x y event)
  (if (equal? event "button-down")
    (process-button-down world-state x y)
    world-state))

(define (restart-or-return-this state)
  (if (should-restart? state) (make-empty-game) state))

(define (process-player-action world-state x y event)
  (let
    ([new-state (process-mouse world-state x y event)])
    (if (equal? world-state new-state)
      world-state
      ; If the player made his move, let the computer play.
      (if (game-finished? new-state)
        (restart-or-return-this new-state)
        (let
          ([after-computer-state (play new-state)])
          (if (game-finished? after-computer-state)
            (restart-or-return-this after-computer-state)
            after-computer-state))))))

(define (draw-vertical-line scene x)
  (add-line scene x 0 x window-side default-line-pen))

(define (draw-horizontal-line scene y)
  (add-line scene 0 y window-side y default-line-pen))

(define (index-from-mouse-click x y)
  (+ (* 3 (quotient y tile-side)) (quotient x tile-side)))

(define (empty-board)
  ((compose
     (lambda (scene) (draw-vertical-line scene tile-side))
     (lambda (scene) (draw-vertical-line scene (* 2 tile-side)))
     (lambda (scene) (draw-horizontal-line scene tile-side))
     (lambda (scene) (draw-horizontal-line scene (* 2 tile-side)))) (empty-scene window-side window-side)))

(define (make-X)
  (let
    ([side (* tile-fill-ratio tile-side)])
    (overlay
      (line side side default-X-pen)
      (line (- side) side default-X-pen))))

(define (make-O)
  (circle (* (/ tile-fill-ratio 2) tile-side) "outline" default-O-pen))

(define (image-from-move move)
  (cond
    [(equal? move 'X) (make-X)]
    [(equal? move 'O) (make-O)]
    [else empty-image]))

(define (draw-move scene x-offset y-offset move)
  (overlay/offset (image-from-move move) x-offset y-offset scene))

(define (draw-line-of-moves scene y-offset list-of-moves)
  (foldl
    (lambda (x-offset move the-scene) (draw-move the-scene x-offset y-offset move))
    scene
    (list tile-side 0 (- tile-side))
    list-of-moves))

(define (draw-moves scene world-state)
  (let ([board (vector->list (game-state world-state))])
    (foldl
      (lambda (y-offset list-of-moves the-scene) (draw-line-of-moves the-scene y-offset list-of-moves))
      scene
      (list tile-side 0 (- tile-side))
      (list (take board 3) (drop (take board 6) 3) (drop board 6)))))

(define (draw-game world-state)
  (draw-moves (empty-board) world-state))

(define (get-end-game-message game)
    (cond
      [(equal? (game-evaluate game) 'O) "You lost. It's OK, the AI is perfect."]
      [(equal? (game-evaluate game) 'X) "You won?! What?!"]
      [else "You tied. Well done."]))

(define (should-restart? world-state)
  (equal? 1 (message-box/custom "The End" (get-end-game-message world-state) "Play Again" "Quit" #f)))

; Evaluates if the Universe should stop, returns #t if the game is finished
; (the player did not reset it).
(define (should-stop? game)
  (game-finished? game))

(big-bang (make-empty-game)
          (name "Tic-tac-toe")
          (stop-when should-stop?)
          (on-mouse process-player-action)
          (to-draw draw-game))
