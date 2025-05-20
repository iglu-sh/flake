_: prev: {
  iglu = {
    iglu-cache = prev.callPackage ./iglu-cache { };
    iglu-controller = prev.callPackage ./iglu-controller { };
    iglu-cache-docker = prev.callPackage ./iglu-cache-docker { };
    iglu-controller-docker = prev.callPackage ./iglu-controller-docker { };
    flakecheck = prev.callPackage ./flakecheck { };
  };
}

