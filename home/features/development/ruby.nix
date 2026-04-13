{
  lib,
  pkgs,
  config,
  ...
}: let
  rubyWithPackages = pkgs.ruby.withPackages (ps:
    with ps; [
      rubyzip
    ]);
in {
  config = lib.mkIf config.features.development.ruby.enable {
    home = {
      packages = [
        rubyWithPackages
      ];
    };
  };
}
