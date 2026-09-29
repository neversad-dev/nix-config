{
  config,
  nix-secrets,
  ...
}: {
  age.secrets = {
    # # A secret specific to this host
    # work-vpn = {
    #   file = "${nix-secrets}/hosts/mbair/work-vpn.age";
    #   owner = "neversad";
    #   mode = "0400";
    # };
    #
    # # A shared secret this host needs access to
    # openai-api-key = {
    #   file = "${nix-secrets}/shared/openai-api-key.age";
    #   owner = "neversad";
    #   mode = "0400";
    # };
  };
}
