{ ... }:

rec {
  # type: path -> path
  getFile = path: dirOf <nixos-config> + /_files + path;

  # type: path -> string
  readFile = path: builtins.readFile (getFile path);
}
