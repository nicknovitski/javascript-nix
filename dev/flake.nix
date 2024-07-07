{
  description = "Development environment and tests for javascript-nix";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    make-shell.url = "github:nicknovitski/make-shell";
    javascript-nix.url = "path:./..";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      imports = [inputs.make-shell.flakeModules.default];
      perSystem = {...}: {
        make-shell.imports = [inputs.javascript-nix.shellModules.default];
        make-shells = {
          default = {pkgs, ...}: {
            packages = [pkgs.alejandra];
          };
          node-test = {
            javascript.node.enable = true;
            javascript.node.corepack-shims = ["yarn" "pnpm"];
          };
          volta-test = {
            javascript.volta.enable = true;
          };
        };
      };
    };
}
