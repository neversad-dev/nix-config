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
  config = lib.mkIf config.development.ruby.enable {
    home = {
      packages = [
        rubyWithPackages
      ];
      sessionVariables = {
      };
      sessionPath = [
      ];
    };
  };
}
