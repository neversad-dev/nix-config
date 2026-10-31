{
  config,
  nix-secrets,
  ...
}: {
  # Android system-level secrets are not supported by nix-on-droid.
  # Use home-manager level secrets (home/base/tui/secrets.nix) instead.
}
