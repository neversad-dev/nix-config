{
  config,
  lib,
  agenix,
  ...
}:
with lib; let
  cfg = config.features.secrets;
in {
  options.features.secrets.enable = mkEnableOption "agenix secret management";

  config = mkIf cfg.enable {
    imports = [
      agenix.homeManagerModules.default
    ];

    # The default key used to decrypt any user-level secrets
    age.identityPaths = [
      "${config.home.homeDirectory}/.ssh/id_ed25519"
    ];
  };
}
