{
  pkgs,
  pkgs-unstable,
  ...
}:
# media - control and enjoy audio/video
{
  home.packages = with pkgs; [
    pavucontrol  # audio control
    imv # simple image viewer

  ];

  programs.mpv = {
    enable = true;
    defaultProfiles = ["gpu-hq"];
    scripts = [ pkgs.mpvScripts.mpris ];
  };

}
