#! /bin/sh

echo "Rebuilding system!"
sudo darwin-rebuild switch --flake ~/nix#cooked
echo "Copying app configs"
python3 load-prefs.py
echo "Done!"