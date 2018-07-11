#lang racket

(require rackunit)
(require "tic-tac-toe.rkt")
(require/expose "tic-tac-toe.rkt" (count-plays list-mean game-won? game-less-than? derive-games derive-games-for-player))

(define-simple-check (check-equal-ignore-ordering? less-than? lst-a lst-b)
                     (equal? (sort lst-a less-than?) (sort lst-b less-than?)))

(check-equal? (count-plays (game (vector empty empty empty empty empty empty empty empty empty)) 'A) 0)
(check-equal? (count-plays (game (vector empty empty empty empty empty empty empty empty empty)) 'B) 0)

(check-equal? (count-plays (game (vector 'A empty empty empty empty empty empty empty empty)) 'A) 1)
(check-equal? (count-plays (game (vector 'A empty empty empty empty empty empty empty empty)) 'B) 0)

(check-equal? (count-plays (game (vector 'A empty empty empty empty 'A empty empty empty)) 'A) 2)
(check-equal? (count-plays (game (vector 'A empty empty empty empty 'A empty empty empty)) 'B) 0)
(check-equal? (count-plays (game (vector 'A empty empty empty empty 'B empty empty empty)) 'A) 1)
(check-equal? (count-plays (game (vector 'A empty empty empty empty 'B empty empty empty)) 'B) 1)
(check-equal? (count-plays (game (vector 'B empty empty empty empty 'B empty empty empty)) 'A) 0)
(check-equal? (count-plays (game (vector 'B empty empty empty empty 'B empty empty empty)) 'B) 2)

(check-equal? (game-evaluate (game (vector empty empty empty empty empty empty empty empty empty))) empty)
(check-equal? (game-evaluate (game (vector 'A empty empty empty empty empty empty empty empty))) empty)
(check-equal? (game-evaluate (game (vector 'A 'A empty empty empty empty empty empty empty))) empty)

; Helper functions
(check-equal? (list-mean empty) 0)
(check-equal? (list-mean (list 0)) 0)
(check-equal? (list-mean (list 1)) 1)
(check-equal? (list-mean (list 0 0)) 0)
(check-equal? (list-mean (list 0 1)) 1/2)
(check-equal? (list-mean (list 1 1)) 1)

; Victory of A
(check-true (game-finished? (game (vector 'A 'B 'A 'A 'B 'B 'A 'A 'B))))
; Victory of B
(check-true (game-finished? (game (vector 'B 'A 'B 'B 'A 'A 'B 'B 'A))))
; Draw
(check-true (game-finished? (game (vector 'A 'B 'A 'B 'B 'A 'A 'A 'B))))
; Unfinished
(check-false (game-finished? (game (vector 'A 'B 'A 'B 'B 'A 'A 'A empty))))

; Horizontals
(check-equal? (game-evaluate (game (vector 'A 'A 'A empty empty empty empty empty empty))) 'A)
(check-equal? (game-evaluate (game (vector empty empty empty 'A 'A 'A empty empty empty))) 'A)
(check-equal? (game-evaluate (game (vector empty empty empty empty empty empty 'A 'A 'A))) 'A)

(check-equal? (game-evaluate (game (vector 'B 'B 'B empty empty empty empty empty empty))) 'B)
(check-equal? (game-evaluate (game (vector empty empty empty 'B 'B 'B empty empty empty))) 'B)
(check-equal? (game-evaluate (game (vector empty empty empty empty empty empty 'B 'B 'B))) 'B)

; Verticals
(check-equal? (game-evaluate (game (vector 'A empty empty 'A empty empty 'A empty empty))) 'A)
(check-equal? (game-evaluate (game (vector empty 'A empty empty 'A empty empty 'A empty))) 'A)
(check-equal? (game-evaluate (game (vector empty empty 'A empty empty 'A empty empty 'A))) 'A)

(check-equal? (game-evaluate (game (vector 'B empty empty 'B empty empty 'B empty empty))) 'B)
(check-equal? (game-evaluate (game (vector empty 'B empty empty 'B empty empty 'B empty))) 'B)
(check-equal? (game-evaluate (game (vector empty empty 'B empty empty 'B empty empty 'B))) 'B)

; Diagonals
(check-equal? (game-evaluate (game (vector 'A empty empty empty 'A empty empty empty 'A))) 'A)
(check-equal? (game-evaluate (game (vector empty empty 'A empty 'A empty 'A empty empty))) 'A)

(check-equal? (game-evaluate (game (vector 'B empty empty empty 'B empty empty empty 'B))) 'B)
(check-equal? (game-evaluate (game (vector empty empty 'B empty 'B empty 'B empty empty))) 'B)

; Deriving games
;
;  XOX    XOX
;  OOX -> OOX
;   XO    XXO
;
(check-equal? (derive-games (game (vector 'X 'O 'X 'O 'O 'X empty 'X 'O))) (list (game (vector 'X 'O 'X 'O 'O 'X 'X 'X 'O))))
;
;  XOX    XOX  XOX
;  O X -> OOX, O X
;   XO     XO  OXO
;
(check-equal-ignore-ordering? game-less-than?
                              (derive-games (game (vector 'X 'O 'X 'O empty 'X empty 'X 'O)))
                              (list (game (vector 'X 'O 'X 'O 'O 'X empty 'X 'O))
                                    (game (vector 'X 'O 'X 'O empty 'X 'O 'X 'O))))

; Playing
;
;  XOX    XOX
;  OOX -> OOX
;   XO    XXO
;
(check-equal? (play (game (vector 'X 'O 'X 'O 'O 'X empty 'X 'O))) (game (vector 'X 'O 'X 'O 'O 'X 'X 'X 'O)))
;
;  XOX    XOX
;  OOX -> OOX
;   X      XO
;
(check-equal? (play (game (vector 'X 'O 'X 'O 'O 'X empty 'X empty))) (game (vector 'X 'O 'X 'O 'O 'X empty 'X 'O)))
;
;  XOX    XOX
;  OO  -> OOX
;   X      X
;
(check-equal? (play (game (vector 'X 'O 'X 'O 'O empty empty 'X empty))) (game (vector 'X 'O 'X 'O 'O 'X empty 'X empty)))

; An empty game should be in fact empty.
(check-true (andmap empty? (vector->list (game-state (make-empty-game)))))

; A solved game should be finished.
(check-true (game-finished? (solve (make-empty-game))))

; A perfectly played game of Tic Tac Toe should have no winners.
(check-false (game-won? (solve (make-empty-game))))
