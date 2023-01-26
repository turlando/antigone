{ lib, ... }:

{
  # type: [AttrSet] -> AttrSet
  mergeAttrsets = xs: lib.lists.foldl
    lib.attrsets.recursiveUpdate
    (builtins.head xs)
    (builtins.tail xs);
}
