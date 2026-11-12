{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  # Android has no system-level agenix secrets; install plain gh there.
  tokenPath =
    if pkgs.stdenv.hostPlatform.isDarwin
    then lib.attrByPath ["age" "secrets" "github-cli" "path"] null osConfig
    else null;
  loadToken = ''
    if [ -z "''${GH_TOKEN:-}''${GITHUB_TOKEN:-}" ]; then
      GH_TOKEN="$(cat ${lib.escapeShellArg tokenPath})" || exit 1
      export GH_TOKEN
    fi
  '';
in {
  programs.gh = {
    enable = true;
    # Git already authenticates over SSH; do not install an HTTPS credential helper.
    gitCredentialHelper.enable = false;
    settings.git_protocol = "ssh";
    package =
      if tokenPath == null
      then pkgs.gh
      else
        pkgs.symlinkJoin {
          name = "gh-with-token-${pkgs.gh.version}";
          paths = [pkgs.gh];
          nativeBuildInputs = [pkgs.makeWrapper];
          # Only the secret's runtime path enters the Nix store, never its contents.
          # Explicit GH_TOKEN/GITHUB_TOKEN overrides remain available for other accounts.
          postBuild = ''
            wrapProgram "$out/bin/gh" --run ${lib.escapeShellArg loadToken}
          '';
          inherit (pkgs.gh) meta;
        };
  };
}
