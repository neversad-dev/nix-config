{
  stdenv,
  fetchFromGitHub,
  ...
}:
stdenv.mkDerivation {
  pname = "herdr-nvim-nav";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "aimdevlee";
    repo = "herdr-nvim-nav";
    # Tip: Use the same rev/hash here as you did in your nvf config
    rev = "ec047fd6d8d0269d54a34e9405af28d8aad4c8f0";
    hash = "sha256-2Sa10OaDgoy/Mw3lglrnmJn4RLUJv0dfU0MhXxXdnJI=";
  };

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out
    # Copy the compiled binary and the manifest to the output directory
    cp -r * $out/
  '';
}
