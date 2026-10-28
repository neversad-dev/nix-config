{
  config,
  agenix,
  ...
}: {
  imports = [
    agenix.homeManagerModules.default
  ];

  # The default key used to decrypt any user-level secrets
  age.identityPaths = [
    "${config.home.homeDirectory}/.ssh/id_ed25519"
  ];
}
