# Darwin home stack

`default.nix` imports shared identity, core, TUI and GUI, plus the Darwin modules
(AeroSpace and SketchyBar). Host choices live in `home/hosts/darwin/`.

System settings and native/Homebrew applications remain in `modules/darwin`.
Home Manager runs only as a nix-darwin module (`hosts/mbair/default.nix`), so
`just darwin` applies both system and user configuration. Use `just darwin-build`
to build the configuration without switching.
