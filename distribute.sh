#!/usr/bin/env bash
#
# Creates a standalone distribution of the game in the tic-tac-toe.zip file.

echo "Creating the executable..."
raco exe game.rkt
echo "Making a standalone distribution..."
raco distribute tic-tac-toe game
rm game
echo "Making a zipfile for the distribution..."
zip -r tic-tac-toe tic-tac-toe
rm -rf tic-tac-toe
if [ ! -f tic-tac-toe.zip ]; then
    echo "Failed!"
    exit 1
else
    echo "Done!"
    exit 0
fi
