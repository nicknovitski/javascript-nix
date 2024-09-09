{
  inputs = {
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
  };

  outputs = _: {
    shellModules.default = {imports = [./shell-modules];};
  };
}
