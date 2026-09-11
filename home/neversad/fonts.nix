{
  config,
  lib,
  pkgs,
  myvars,
  ...
}: {
  home.packages = with pkgs; [
    maple-mono.NF-unhinted
  ];

  myFonts = {
    main = "Maple Mono NF";
    mono = "Maple Mono NF Mono";
    propo = "Maple Mono NF propo";
  };
}
