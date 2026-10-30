# Git + SSH settings for Acode's built-in Alpine terminal (Git SCM plugin).
#
# Acode's Alpine can't see nix-on-droid's home, and has no Nix. On every
# switch, export the generated git/ssh config to shared storage, with
# /nix/store paths replaced by copies. scripts/acode-setup.sh (run once in
# Acode's terminal) installs the tools and *includes* these files, so later
# setting changes reach Acode with just `just droid`.
{
  config,
  lib,
  pkgs,
  myvars,
  ...
}: let
  # Same path from both sides: nix-on-droid and Acode's sandbox (binds /storage).
  bundleDir = "/storage/emulated/0/nix-on-droid/acode";

  # git `[include]` files live in the store (e.g. delta's catppuccin theme):
  # copy each into the bundle and point the config at the copy.
  storeIncludes =
    lib.filter (p: lib.hasPrefix builtins.storeDir p)
    (map (i: toString i.path) config.programs.git.includes);
  includeName = p: builtins.baseNameOf p;
  gitconfig =
    builtins.replaceStrings
    storeIncludes
    (map (p: "${bundleDir}/includes/${includeName p}") storeIncludes)
    config.xdg.configFile."git/config".text;

  bundle = pkgs.runCommand "acode-bundle" {} ''
    mkdir -p $out/hooks $out/includes
    cp ${pkgs.writeText "gitconfig" gitconfig} $out/gitconfig
    cp ${pkgs.writeText "ignore" config.xdg.configFile."git/ignore".text} $out/ignore
    cp ${config.home.file.".config/git/message".source} $out/message
    cp ${config.home.file.".config/git/hooks/commit-msg".source} $out/hooks/commit-msg
    cp ${pkgs.writeText "ssh_config" config.home.file.".ssh/config".text} $out/ssh_config
    printf '%s\n' ${lib.escapeShellArg myvars.githubHostKey} > $out/known_hosts
    ${lib.concatMapStrings (p: "cp ${p} $out/includes/${includeName p}\n") storeIncludes}
  '';
in {
  # Real files, not symlinks: Acode can't follow links into /nix/store.
  home.activation.exportAcodeBundle = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -d /storage/emulated/0 ]; then
      $DRY_RUN_CMD rm -rf ${bundleDir}
      $DRY_RUN_CMD mkdir -p ${bundleDir}
      $DRY_RUN_CMD cp -rL --no-preserve=mode ${bundle}/. ${bundleDir}/
    fi
  '';
}
