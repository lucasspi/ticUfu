#lang racket

(require "tic-tac-toe.rkt")

(displayln "Computer against computer...")
(time (displayln (game-to-string (solve (make-empty-game)))))
