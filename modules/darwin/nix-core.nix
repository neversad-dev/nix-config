{...}: {
  # Nix is installed/managed outside nix-darwin (e.g. Determinate installer).
  nix.enable = false;

  # Rosetta must be installed with `softwareupdate --install-rosetta --agree-to-license`
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';
}
