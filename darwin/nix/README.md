# `nix-darwin` macOS Device Configuration
To install a nix-darwin configuration on a new macOS device, follow these steps.

1. Ensure nix is installed: `sh <(curl -L https://nixos.org/nix/install)`
2. Restart terminal session.
3. `cd ~/`
4. Clone this repository: `git clone git@github.com:ryanwittmers/.dotfiles.git`
5. `cd ./dotfiles/darwin/nix/`
6. `nix run nix-darwin -- switch --flake .#workMac`
    1. Note: If you're not already, there will be popups to sign into the App Store to install the native macOS applications.