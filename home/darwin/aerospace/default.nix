{
  pkgs,
  mylib,
  ...
}: let
  aerospaceConfig = builtins.readFile ./aerospace.toml;
in {
  # Use mkEditableConfig for aerospace.toml to allow manual editing
  home.activation.copyAerospaceConfig = mylib.mkEditableConfig {
    name = "Aerospace";
    configPath = "$HOME/.aerospace.toml";
    content = aerospaceConfig;
    pkgs = pkgs;
  };
}
