echo "Setting everything up! First let's install Nix"
# Install Nix
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
# Restart terminal
exec zsh
echo "Now we'll build & configure your apps & system settings"
# Build system
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/nix#cooked
echo "Done setting up system!"