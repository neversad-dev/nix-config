# Vendored from nixpkgs unstable (pkgs/by-name/tu/tuxedo/package.nix),
# where it's only in unstable; building it here against 25.11's toolchain
# (newer rust, glibc 2.40 — unstable's 2.42+ binaries don't run on Android).
# Usage: pkgs.nixos2511.callPackage ./tuxedo.nix {}
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tuxedo";
  version = "2026.8.1";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "webstonehq";
    repo = "tuxedo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-E7zjvg5EMBq9hDjILKsNHb7ig90DcS28x/db8v0b5x0=";
  };

  cargoHash = "sha256-UpSIqUA+mJe31m2Oo6P1ZXvV9+fi90fUYg7OWWts2Js=";

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  checkFlags = [
    # Failure
    "--skip=insert_dialog_after_nl_parse"
  ];

  meta = {
    description = "fast, keyboard-driven terminal UI for todo.txt";
    homepage = "https://github.com/webstonehq/tuxedo";
    license = lib.licenses.mit;
    mainProgram = "tuxedo";
  };
})
