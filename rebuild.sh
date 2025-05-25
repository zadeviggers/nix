#! /bin/sh

echo "Rebuilding system!"
sudo darwin-rebuild switch --flake ~/nix#cooked
echo "Done!"