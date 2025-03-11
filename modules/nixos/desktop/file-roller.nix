{
  pkgs,
  ...
}: {
  programs = {
    # Create and modify archives
    file-roller = {
      enable = true;
    };
  };
}
