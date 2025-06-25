{pkgs, ...}: {
  home.packages = with pkgs; [
    fastfetch
  ];

  home.file.".config/fastfetch/config.jsonc".text = ''
    {
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "modules": [
        "title",
        "separator",
        "os",
        {
            "type": "host",
            "format": "{/2}{-}{/}{2}{?3} {3}{?}"
        },
        "kernel",
        "uptime",
        {
            "type": "battery",
            "format": "{/4}{-}{/}{4}{?5} [{5}]{?}"
        },
        "break",
        "packages",
        "shell",
        "display",
        "terminal",
        "break",
        "cpu",
        {
            "type": "gpu",
            "key": "GPU"
        },
        "memory",
        "break",
        "colors"
      ]
    }
  '';

  programs.zsh = {
    initContent = ''
      fastfetch
    '';
  };

  programs.bash = {
    initExtra = ''
      fastfetch
    '';
  };
}
