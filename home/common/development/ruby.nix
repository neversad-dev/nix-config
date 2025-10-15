{
  lib,
  pkgs,
  config,
  mylib,
  ...
}: let
  rubyWithPackages = pkgs.ruby.withPackages (ps:
    with ps; [
      rubyzip
    ]);
in {
  config = lib.mkIf config.development.ruby.enable {
    home = {
      packages = with pkgs; [
        rubyWithPackages
      ];
      sessionVariables = {
      };
      sessionPath = [
      ];
    };
  };
}
