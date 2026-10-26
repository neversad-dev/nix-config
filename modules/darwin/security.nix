{...}: {
  # Remote login is disabled by default; if you toggle it on (e.g. for deploy-rs
  # troubleshooting), the hardened drop-in below is already in place.
  services.openssh.enable = false;

  # Disable password authentication for SSH
  environment.etc."ssh/sshd_config.d/200-disable-password-auth.conf".text = ''
    PasswordAuthentication no
    KbdInteractiveAuthentication no
  '';
}
