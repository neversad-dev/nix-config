{pkgs, ...}: {
  home.packages = with pkgs; [
    dust
  ];

  home.file.".config/dust/config.toml".text = ''
    # Do not display hidden files
    ignore-hidden=true

    # print sizes in powers of 1000 (e.g., 1.1G)
    output-format="si"
  '';
}
