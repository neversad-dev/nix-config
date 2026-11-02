{
  nix-secrets,
  myvars,
  ...
}: {
  # Host-specific system secrets belong here. Encrypt them for this host's
  # /etc/ssh/ssh_host_ed25519_key; shared secrets belong in secrets/darwin.nix.
  age.secrets = {
    # "work-vpn" = {
    #   file = "${nix-secrets}/hosts/mbair/work-vpn.age";
    #   owner = myvars.primaryUser;
    #   mode = "0400";
    # };
  };
}
