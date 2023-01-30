{ lib, ... }:

{
  # type: AttrSet -> [String]
  getNames = x: lib.attrsets.mapAttrsToList (name: value: name) x;

  # type: [AttrSet] -> AttrSet
  mergeAttrsets = xs: lib.lists.foldl
    lib.attrsets.recursiveUpdate
    (builtins.head xs)
    (builtins.tail xs);
}
