{
  stdenv,
  fetchFromGitHub,
  ...
}:
stdenv.mkDerivation {
  pname = "herdr-worktrunk";
  version = "unstable-2026-09-21";

  src = fetchFromGitHub {
    owner = "devashish2203";
    repo = "herdr-worktrunk";
    rev = "8ceca541de8fb0d6006727e172534e1e2af17224";
    hash = "sha256-unoP8GUAULiOBTrS/+noCed/VOw6yqBObqHmit17xy0=";
  };

  # No build required — the plugin is a collection of bash scripts
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
}
