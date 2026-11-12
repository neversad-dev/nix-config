{pkgs, ...}: {
  # Standalone repository browser. No token or gh authentication integration.
  home.packages = [pkgs.ghgrab];
}
