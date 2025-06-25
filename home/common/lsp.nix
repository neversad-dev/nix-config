{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    nixd
    alejandra # formatter for nix
  ];

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
}
