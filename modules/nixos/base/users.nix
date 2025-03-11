{ myvars, config, lib, pkgs, ... }: {

  # Don't allow mutation of users outside the config.
  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${myvars.username} = {
    home = "/home/${myvars.username}";
    isNormalUser = true;
    description = "${myvars.username}";
    extraGroups = [
      myvars.username
      "users"
      "wheel" # Enable ‘sudo’ for the user.
      "video"
      "audio"
      "networkmanager"
      "lp"
      "input"
      "scanner"
      "libvirtd" # Virtualization
    ];
    initialPassword = "password";
  };





}
