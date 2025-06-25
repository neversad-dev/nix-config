{mylib, ...}: {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      ../common
    ];
}
