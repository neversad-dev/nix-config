{...}: {
  # Shared configuration for mbair
  # This file is imported by both home.nix and default.nix

  development = {
    vscode.enable = true;
    cursor.enable = true;
    android.enable = false;
    flutter.enable = false;
  };
  gaming.enable = false;
}
