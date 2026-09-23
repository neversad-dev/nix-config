{...}: {
  # Shared configuration for mbair
  # This file is imported by both home.nix and default.nix

  features = {
    development = {
      vscode.enable = false; # problems on macos
      cursor.enable = false;
      android.enable = false;
    };
    gaming.enable = true;
  };
}
